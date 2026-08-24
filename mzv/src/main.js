#!/usr/bin/env node

import dns from "dns";
import net from "net";
import https from "https";
import http from "http";
import { URL } from "url";

const COMMON_PORTS = {
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
};

// ===================== Utility Functions =====================

function formatOutput(data) {
  if (data.error) {
    return `[ERROR] ${data.error}`;
  }

  if (data.type === "public_ip") {
    return `Public IP: ${data.ip}`;
  }

  if (data.type === "resolve") {
    let result = `Host: ${data.host}\n`;
    data.ips.forEach((ip) => {
      result += `- ${ip}\n`;
    });
    return result.trim();
  }

  if (data.type === "port_scan") {
    let result = `Host: ${data.host}\n`;
    data.ports.forEach((p) => {
      result += `${String(p.port).padStart(5)} | ${String(p.status).padEnd(6)} | ${p.service}\n`;
    });
    return result.trim();
  }

  if (data.type === "http_headers") {
    let result = `URL: ${data.url}\n`;
    Object.entries(data.headers).forEach(([key, value]) => {
      result += `- ${key}: ${value}\n`;
    });
    return result.trim();
  }

  if (data.type === "security_check") {
    let result = `URL: ${data.url}\n`;
    data.findings.forEach((f) => {
      if (f.status === "present") {
        result += `✓ ${f.header}: ${f.value}\n`;
      } else {
        result += `✗ ${f.header}: MISSING (${f.description})\n`;
      }
    });
    return result.trim();
  }

  if (data.type === "whois") {
    let result = `WHOIS Info for ${data.domain}:\n`;
    if (data.info) {
      Object.entries(data.info).forEach(([key, value]) => {
        result += `- ${key}: ${value}\n`;
      });
    } else {
      result += data.raw;
    }
    return result.trim();
  }

  if (data.type === "dns_lookup") {
    let result = `DNS Lookup for ${data.domain}:\n`;
    if (data.records) {
      Object.entries(data.records).forEach(([type, values]) => {
        result += `${type}:\n`;
        values.forEach((v) => {
          result += `  - ${JSON.stringify(v)}\n`;
        });
      });
    }
    return result.trim();
  }

  if (data.type === "ssl_check") {
    let result = `SSL/TLS Check for ${data.host}:${data.port}\n`;
    if (data.cert) {
      result += `- Subject: ${data.cert.subject}\n`;
      result += `- Issuer: ${data.cert.issuer}\n`;
      result += `- Valid From: ${data.cert.valid_from}\n`;
      result += `- Valid Until: ${data.cert.valid_to}\n`;
      result += `- CN: ${data.cert.cn}\n`;
      result += `- Alt Names: ${data.cert.altNames}\n`;
    } else {
      result += `- Error: ${data.error}\n`;
    }
    return result.trim();
  }

  return JSON.stringify(data, null, 2);
}

// ===================== Tools =====================

async function getPublicIP() {
  return new Promise((resolve) => {
    https
      .get("https://api.ipify.org?format=json", (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          try {
            const result = JSON.parse(data);
            resolve({ type: "public_ip", ip: result.ip });
          } catch (e) {
            resolve({ error: "Failed to parse response" });
          }
        });
      })
      .on("error", (e) => {
        resolve({ error: e.message });
      });
  });
}

async function resolveHost(host) {
  return new Promise((resolve) => {
    dns.resolve4(host, (err, addresses) => {
      if (err) {
        resolve({ error: err.message });
      } else {
        resolve({
          type: "resolve",
          host: host,
          ips: addresses,
        });
      }
    });
  });
}

async function portScan(host, ports, timeout = 1000) {
  const results = [];
  for (const port of ports) {
    const result = await new Promise((resolve) => {
      const socket = net.createConnection({ host, port, timeout }, () => {
        socket.destroy();
        resolve({
          port,
          status: "open",
          service: COMMON_PORTS[port] || "Unknown",
        });
      });

      socket.on("error", () => {
        resolve({
          port,
          status: "closed",
          service: COMMON_PORTS[port] || "Unknown",
        });
      });

      socket.on("timeout", () => {
        socket.destroy();
        resolve({
          port,
          status: "closed",
          service: COMMON_PORTS[port] || "Unknown",
        });
      });
    });
    results.push(result);
  }
  return {
    type: "port_scan",
    host,
    ports: results,
  };
}

async function fetchHeaders(urlStr) {
  return new Promise((resolve) => {
    const url = new URL(urlStr.startsWith("http") ? urlStr : `https://${urlStr}`);
    const client = url.protocol === "https:" ? https : http;

    client
      .request(
        {
          hostname: url.hostname,
          port: url.port,
          path: url.pathname + url.search,
          method: "HEAD",
        },
        (res) => {
          const headers = {};
          Object.entries(res.headers).forEach(([key, value]) => {
            headers[key] = value;
          });
          resolve({
            type: "http_headers",
            url: url.href,
            headers,
          });
        }
      )
      .on("error", (e) => {
        // Fallback to GET if HEAD fails
        client
          .request(
            {
              hostname: url.hostname,
              port: url.port,
              path: url.pathname + url.search,
              method: "GET",
            },
            (res) => {
              const headers = {};
              Object.entries(res.headers).forEach(([key, value]) => {
                headers[key] = value;
              });
              resolve({
                type: "http_headers",
                url: url.href,
                headers,
              });
            }
          )
          .on("error", (e2) => {
            resolve({ error: e2.message });
          })
          .end();
      })
      .end();
  });
}

async function securityHeaderCheck(urlStr) {
  const headerData = await fetchHeaders(urlStr);
  if (headerData.error) {
    return headerData;
  }

  const requiredHeaders = {
    "strict-transport-security": "HSTS - Force HTTPS",
    "x-frame-options": "Clickjacking mitigation",
    "x-content-type-options": "MIME sniffing protection",
    "content-security-policy": "Content Security Policy",
    "x-xss-protection": "XSS protection",
  };

  const findings = [];
  const lowerHeaders = {};
  Object.entries(headerData.headers).forEach(([key, value]) => {
    lowerHeaders[key.toLowerCase()] = value;
  });

  Object.entries(requiredHeaders).forEach(([header, description]) => {
    if (lowerHeaders[header]) {
      findings.push({
        header,
        status: "present",
        description,
        value: lowerHeaders[header],
      });
    } else {
      findings.push({
        header,
        status: "missing",
        description,
      });
    }
  });

  return {
    type: "security_check",
    url: headerData.url,
    findings,
  };
}

async function dnslookup(domain) {
  return new Promise((resolve) => {
    const records = {};

    Promise.all([
      new Promise((res) => {
        dns.resolve(domain, "A", (err, data) => {
          if (!err) records.A = data;
          res();
        });
      }),
      new Promise((res) => {
        dns.resolve(domain, "MX", (err, data) => {
          if (!err) records.MX = data;
          res();
        });
      }),
      new Promise((res) => {
        dns.resolve(domain, "NS", (err, data) => {
          if (!err) records.NS = data;
          res();
        });
      }),
      new Promise((res) => {
        dns.resolve(domain, "TXT", (err, data) => {
          if (!err) records.TXT = data;
          res();
        });
      }),
    ]).then(() => {
      resolve({
        type: "dns_lookup",
        domain,
        records: Object.keys(records).length > 0 ? records : null,
      });
    });
  });
}

async function sslCheck(host, port = 443) {
  return new Promise((resolve) => {
    const socket = net.createConnection({ host, port }, () => {
      const options = {
        host,
        port,
        method: "HEAD",
      };

      const req = https.request(options, (res) => {
        const cert = res.socket.getPeerCertificate();
        socket.destroy();
        resolve({
          type: "ssl_check",
          host,
          port,
          cert: cert
            ? {
                subject: cert.subject ? JSON.stringify(cert.subject) : "N/A",
                issuer: cert.issuer ? JSON.stringify(cert.issuer) : "N/A",
                valid_from: cert.valid_from || "N/A",
                valid_to: cert.valid_to || "N/A",
                cn: cert.subjectaltname || cert.subject?.CN || "N/A",
                altNames: cert.subjectaltname || "N/A",
              }
            : null,
        });
      });

      req.on("error", (e) => {
        socket.destroy();
        resolve({
          type: "ssl_check",
          host,
          port,
          error: e.message,
        });
      });

      req.end();
    });

    socket.on("error", (e) => {
      resolve({
        type: "ssl_check",
        host,
        port,
        error: e.message,
      });
    });
  });
}

async function toolList() {
  const tools = [
    { name: "tool-list", desc: "Tampilkan daftar tools yang tersedia" },
    { name: "public-ip", desc: "Tampilkan public IP address" },
    { name: "resolve <host>", desc: "Resolve hostname ke IP address" },
    { name: "port-scan <host>", desc: "Scan port-port umum pada host" },
    { name: "http-headers <url>", desc: "Ambil HTTP response headers" },
    { name: "security-check <url>", desc: "Periksa security headers" },
    { name: "dns-lookup <domain>", desc: "Lakukan DNS lookup lengkap" },
    { name: "ssl-check <host> [port]", desc: "Periksa SSL/TLS certificate" },
  ];

  console.log("=== Available Tools ===\n");
  tools.forEach((t) => {
    console.log(`${t.name.padEnd(30)} - ${t.desc}`);
  });
  console.log(
    "\nUsage: node src/main.js <command> [options]\nExample: node src/main.js public-ip"
  );
}

// ===================== Main =====================

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
    await toolList();
    return;
  }

  const command = args[0];
  let result;

  try {
    switch (command) {
      case "tool-list":
        await toolList();
        return;

      case "public-ip":
        result = await getPublicIP();
        break;

      case "resolve":
        if (!args[1]) {
          console.error("Error: Host argument required");
          return;
        }
        result = await resolveHost(args[1]);
        break;

      case "port-scan":
        if (!args[1]) {
          console.error("Error: Host argument required");
          return;
        }
        const ports = args[2]
          ? args[2].split(",").map((p) => parseInt(p))
          : Object.keys(COMMON_PORTS).map((p) => parseInt(p));
        result = await portScan(args[1], ports, parseInt(args[3]) || 1000);
        break;

      case "http-headers":
        if (!args[1]) {
          console.error("Error: URL argument required");
          return;
        }
        result = await fetchHeaders(args[1]);
        break;

      case "security-check":
        if (!args[1]) {
          console.error("Error: URL argument required");
          return;
        }
        result = await securityHeaderCheck(args[1]);
        break;

      case "dns-lookup":
        if (!args[1]) {
          console.error("Error: Domain argument required");
          return;
        }
        result = await dnslookup(args[1]);
        break;

      case "ssl-check":
        if (!args[1]) {
          console.error("Error: Host argument required");
          return;
        }
        const sslPort = parseInt(args[2]) || 443;
        result = await sslCheck(args[1], sslPort);
        break;

      default:
        console.error(`Unknown command: ${command}`);
        await toolList();
        return;
    }

    console.log(formatOutput(result));
  } catch (error) {
    console.error(`Error: ${error.message}`);
  }
}

main();
