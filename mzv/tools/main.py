#!/usr/bin/env python3
"""Security reconnaissance CLI for authorized, defensive analysis."""

from __future__ import annotations

import argparse
import json
import socket
import ssl
import sys
from datetime import datetime
from typing import Dict, Iterable, List, Tuple
from urllib import error, request

COMMON_PORTS = {
    21: "FTP",
    22: "SSH",
    23: "Telnet",
    25: "SMTP",
    53: "DNS",
    80: "HTTP",
    110: "POP3",
    111: "RPC",
    135: "RPC-Endpoint",
    139: "NetBIOS",
    143: "IMAP",
    443: "HTTPS",
    465: "SMTPS",
    587: "SMTP-Submission",
    993: "IMAPS",
    995: "POP3S",
    1433: "MSSQL",
    1521: "Oracle",
    3306: "MySQL",
    3389: "RDP",
    5432: "PostgreSQL",
    8080: "HTTP-Alt",
    8443: "HTTPS-Alt",
    9200: "Elasticsearch",
    9300: "Elasticsearch-Cluster",
    27017: "MongoDB",
}


def get_public_ip() -> Dict[str, object]:
    try:
        with request.urlopen("https://api.ipify.org?format=json", timeout=8) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
            return {"status": "ok", "public_ip": payload.get("ip")}
    except Exception as exc:  # pragma: no cover - network dependent
        return {"status": "error", "message": str(exc)}


def resolve_host(host: str) -> Dict[str, object]:
    try:
        infos = socket.getaddrinfo(host, None)
        ips = sorted({item[4][0] for item in infos})
        return {"status": "ok", "host": host, "ips": ips}
    except socket.gaierror as exc:
        return {"status": "error", "message": str(exc)}


def port_scan(host: str, ports: Iterable[int], timeout: float = 1.0) -> List[Dict[str, object]]:
    results: List[Dict[str, object]] = []
    for port in ports:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        try:
            result = sock.connect_ex((host, int(port)))
            if result == 0:
                service = COMMON_PORTS.get(int(port), "Unknown")
                results.append({"port": int(port), "status": "open", "service": service})
            else:
                results.append({"port": int(port), "status": "closed", "service": COMMON_PORTS.get(int(port), "Unknown")})
        except OSError as exc:
            results.append({"port": int(port), "status": "error", "service": COMMON_PORTS.get(int(port), "Unknown"), "message": str(exc)})
        finally:
            sock.close()
    return results


def fetch_headers(url: str) -> Dict[str, object]:
    parsed_url = url if url.startswith("http://") or url.startswith("https://") else f"https://{url}"
    req = request.Request(parsed_url, method="HEAD")
    try:
        with request.urlopen(req, timeout=10) as resp:
            headers = dict(resp.headers)
            return {"status": "ok", "url": parsed_url, "headers": headers}
    except Exception:
        req = request.Request(parsed_url, method="GET")
        try:
            with request.urlopen(req, timeout=10) as resp:
                headers = dict(resp.headers)
                return {"status": "ok", "url": parsed_url, "headers": headers}
        except Exception as exc:
            return {"status": "error", "url": parsed_url, "message": str(exc)}


def security_header_check(url: str) -> Dict[str, object]:
    data = fetch_headers(url)
    if data.get("status") != "ok":
        return data

    required = {
        "strict-transport-security": "HSTS",
        "x-frame-options": "Clickjacking mitigation",
        "x-content-type-options": "MIME sniffing protection",
        "content-security-policy": "Content Security Policy",
    }
    findings = []
    headers = {key.lower(): value for key, value in data["headers"].items()}
    for key, label in required.items():
        if key in headers:
            findings.append({"header": key, "status": "present", "description": label, "value": headers[key]})
        else:
            findings.append({"header": key, "status": "missing", "description": label})
    return {"status": "ok", "url": data["url"], "findings": findings}


def get_tls_info(host: str, port: int = 443) -> Dict[str, object]:
    ctx = ssl.create_default_context()
    try:
        with ctx.wrap_socket(socket.socket(socket.AF_INET), server_hostname=host) as sock:
            sock.settimeout(8)
            sock.connect((host, port))
            cert = sock.getpeercert()
            return {
                "status": "ok",
                "host": host,
                "port": port,
                "version": sock.version(),
                "cipher": sock.cipher(),
                "issuer": cert.get("issuer", ""),
                "subject": cert.get("subject", ""),
                "not_before": cert.get("notBefore", ""),
                "not_after": cert.get("notAfter", ""),
            }
    except Exception as exc:
        return {"status": "error", "host": host, "port": port, "message": str(exc)}


def format_result(payload: Dict[str, object]) -> str:
    if payload.get("status") == "error":
        return f"[ERROR] {payload.get('message', 'Unknown error')}"

    if "public_ip" in payload:
        return f"Public IP: {payload['public_ip']}"

    if "ips" in payload:
        lines = [f"Host: {payload['host']}"]
        for ip in payload["ips"]:
            lines.append(f"- {ip}")
        return "\n".join(lines)

    if "findings" in payload:
        lines = [f"URL: {payload['url']}"]
        for item in payload["findings"]:
            status = item["status"]
            lines.append(f"- {item['header']}: {status.upper()} | {item.get('description', '')}")
            if item.get("value"):
                lines.append(f"  value: {item['value']}")
        return "\n".join(lines)

    if "version" in payload:
        lines = [
            f"Host: {payload['host']}:{payload['port']}",
            f"TLS: {payload['version']}",
            f"Cipher: {payload['cipher']}",
        ]
        if payload.get("issuer"):
            lines.append(f"Issuer: {payload['issuer']}")
        if payload.get("subject"):
            lines.append(f"Subject: {payload['subject']}")
        return "\n".join(lines)

    if isinstance(payload.get("headers"), dict):
        lines = [f"URL: {payload['url']}"]
        for key, value in payload["headers"].items():
            lines.append(f"- {key}: {value}")
        return "\n".join(lines)

    if isinstance(payload.get("results"), list):
        lines = []
        for item in payload["results"]:
            lines.append(f"{item['port']:>5} | {item['status']:<6} | {item['service']}")
        return "\n".join(lines)

    if isinstance(payload.get("ports"), list):
        lines = [f"Host: {payload['host']}"]
        for item in payload["ports"]:
            lines.append(f"- {item['port']}: {item['status']} ({item['service']})")
        return "\n".join(lines)

    return json.dumps(payload, indent=2, ensure_ascii=False)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Security reconnaissance CLI for defensive analysis")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("tool-list", help="Show available tools")
    subparsers.add_parser("public-ip", help="Display the public IP address")

    host_parser = subparsers.add_parser("resolve", help="Resolve host to IP addresses")
    host_parser.add_argument("host", help="Target domain or hostname")

    scan_parser = subparsers.add_parser("port-scan", help="Check whether common ports are open")
    scan_parser.add_argument("host", help="Target host or IP address")
    scan_parser.add_argument("--ports", default="21,22,23,25,53,80,110,143,443,465,587,993,995,1433,1521,3306,3389,5432,8080,8443,9200,9300,27017", help="Comma-separated port list")
    scan_parser.add_argument("--timeout", type=float, default=1.0, help="Connection timeout in seconds")

    header_parser = subparsers.add_parser("http-headers", help="Inspect HTTP response headers")
    header_parser.add_argument("url", help="Target HTTP/HTTPS URL")

    security_parser = subparsers.add_parser("security-check", help="Check common security headers")
    security_parser.add_argument("url", help="Target HTTP/HTTPS URL")

    tls_parser = subparsers.add_parser("tls-info", help="Inspect TLS certificate information")
    tls_parser.add_argument("host", help="Target hostname or IP")
    tls_parser.add_argument("--port", type=int, default=443)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "tool-list":
        tools = [
            "public-ip",
            "resolve",
            "port-scan",
            "http-headers",
            "security-check",
            "tls-info",
        ]
        print("Available tools:")
        for tool in tools:
            print(f"- {tool}")
        return 0

    if args.command == "public-ip":
        print(format_result(get_public_ip()))
        return 0

    if args.command == "resolve":
        print(format_result(resolve_host(args.host)))
        return 0

    if args.command == "port-scan":
        ports = []
        for raw in str(args.ports).split(","):
            port = raw.strip()
            if port:
                try:
                    ports.append(int(port))
                except ValueError:
                    print(f"[WARNING] Ignoring invalid port value: {port}")
        payload = {"host": args.host, "ports": port_scan(args.host, ports, timeout=args.timeout)}
        print(format_result(payload))
        return 0

    if args.command == "http-headers":
        print(format_result(fetch_headers(args.url)))
        return 0

    if args.command == "security-check":
        print(format_result(security_header_check(args.url)))
        return 0

    if args.command == "tls-info":
        print(format_result(get_tls_info(args.host, port=args.port)))
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
