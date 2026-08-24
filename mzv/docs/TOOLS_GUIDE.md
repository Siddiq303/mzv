# SECURITY RECON CLI - PANDUAN LENGKAP SEMUA TOOLS

## 📋 Daftar Semua Tools

Terdapat 7 tools utama dalam aplikasi ini:

1. **public-ip** - Tampilkan IP publik kamu
2. **resolve** - Resolve hostname ke IP address
3. **port-scan** - Scan port-port pada host
4. **http-headers** - Ambil HTTP response headers
5. **security-check** - Periksa security headers website
6. **dns-lookup** - Lakukan DNS lookup
7. **ssl-check** - Periksa SSL/TLS certificate

---

## 1️⃣ TOOL: public-ip

### Fungsi
Mendapatkan alamat IP publik kamu (IP yang terlihat dari internet).

### Syntax
```bash
.\recon.bat public-ip
```

### Penjelasan
- Tidak memerlukan parameter tambahan
- Menghubungi service eksternal untuk mendapatkan IP publik
- Berguna untuk mengetahui IP asli kamu dari perspektif internet

### Contoh Output
```
[*] Fetching public IP...
Public IP: 103.116.49.137
```

### Use Case
- Cek IP lokal dari internet
- Debugging koneksi internet
- Identifikasi lokasi geografis (berdasarkan IP)

---

## 2️⃣ TOOL: resolve

### Fungsi
Mengubah nama domain/hostname menjadi IP address (DNS resolution).

### Syntax
```bash
.\recon.bat resolve <hostname>
```

### Parameter
- `<hostname>` - Nama domain atau hostname yang ingin diresolvse

### Penjelasan
- Melakukan DNS query untuk mendapatkan IP dari domain
- Berguna untuk mengetahui server IP dari sebuah website
- Bisa mendeteksi jika domain tidak valid

### Contoh 1: Resolve google.com
```bash
.\recon.bat resolve google.com
```

Output:
```
[*] Resolving google.com...
Host: google.com
  216.239.38.120
```

**Penjelasan**: Domain google.com resolve ke IP 216.239.38.120

### Contoh 2: Resolve github.com
```bash
.\recon.bat resolve github.com
```

Output:
```
[*] Resolving github.com...
Host: github.com
  140.82.113.3
  140.82.114.3
  140.82.115.3
```

**Penjelasan**: Satu domain bisa memiliki multiple IP (load balancing)

### Use Case
- Mengetahui server IP dari website
- Debugging DNS issues
- Identifikasi multiple servers (CDN, load balancer)
- Social engineering reconnaissance

---

## 3️⃣ TOOL: port-scan

### Fungsi
Memindai port-port pada host untuk melihat mana yang terbuka.

### Syntax
```bash
.\recon.bat port-scan <hostname> [ports]
```

### Parameter
- `<hostname>` - Target host atau IP yang ingin di-scan
- `[ports]` - (Opsional) Port list (comma-separated). Default: scan 25 port umum

### Penjelasan
- Mengecek konektivitas TCP ke port spesifik
- Port terbuka = ada service yang listening
- Port tertutup = tidak ada service atau firewall blocking
- Timeout per port: 1000ms (1 detik)

### Contoh 1: Scan semua port umum
```bash
.\recon.bat port-scan google.com
```

Output:
```
[*] Scanning google.com...

  21 : closed [FTP]
  22 : closed [SSH]
  23 : closed [Telnet]
  25 : closed [SMTP]
  53 : OPEN   [DNS]
  80 : OPEN   [HTTP]
  110 : closed [POP3]
  143 : closed [IMAP]
  443 : OPEN   [HTTPS]
  ... (25 port total)
```

**Penjelasan**: 
- Port 53 (DNS) OPEN = DNS service aktif
- Port 80 (HTTP) OPEN = Web server aktif
- Port 443 (HTTPS) OPEN = Secure web aktif
- Port 22 (SSH) CLOSED = Tidak ada SSH service

### Contoh 2: Scan port spesifik
```bash
.\recon.bat port-scan google.com 22,80,443,3306,8080
```

Output:
```
[*] Scanning google.com...

  22 : closed [SSH]
  80 : OPEN   [HTTP]
  443 : OPEN   [HTTPS]
  3306 : closed [MySQL]
  8080 : closed [HTTP-Alt]
```

**Penjelasan**: Hanya scan 5 port yang kita spesifikasikan

### Common Ports Reference
```
21   = FTP (File Transfer)
22   = SSH (Secure Shell)
23   = Telnet (Remote Access)
25   = SMTP (Email)
53   = DNS (Domain Name)
80   = HTTP (Web)
110  = POP3 (Email)
143  = IMAP (Email)
443  = HTTPS (Secure Web)
465  = SMTPS (Secure Email)
587  = SMTP-Submission
993  = IMAPS (Secure Email)
995  = POP3S (Secure Email)
1433 = MSSQL (Microsoft SQL)
1521 = Oracle (Database)
3306 = MySQL (Database)
3389 = RDP (Remote Desktop)
5432 = PostgreSQL (Database)
8080 = HTTP-Alt (Alternate Web)
9200 = Elasticsearch (Search)
27017 = MongoDB (NoSQL)
```

### Use Case
- Identifikasi service yang running
- Deteksi open ports (security audit)
- Mencari vulnerabilities melalui port yang tidak semestinya terbuka
- Network reconnaissance
- Troubleshoot firewall rules

---

## 4️⃣ TOOL: http-headers

### Fungsi
Mengambil HTTP response headers dari sebuah website.

### Syntax
```bash
.\recon.bat http-headers <url>
```

### Parameter
- `<url>` - URL atau domain yang ingin dicek (bisa tanpa http://)

### Penjelasan
- Mengirim HTTP request dan menampilkan response headers
- Headers berisi informasi tentang server, content-type, cache, dll
- Bisa mengungkap informasi sensitif tentang server

### Contoh: Ambil headers dari google.com
```bash
.\recon.bat http-headers google.com
```

Output:
```
[*] Fetching headers from https://google.com...

URL: https://www.google.com/

content-length : 219
content-type : text/html; charset=UTF-8
content-security-policy : script-src 'nonce-...' ...
x-ua-compatible : IE=edge
cache-control : private, max-age=0
expires : Thu, 01 Jan 1970 00:00:01 GMT
date : Fri, 16 Aug 2024 10:30:15 GMT
server : gws
```

### Informasi Penting dari Headers

- **server** - Jenis & versi web server (bisa reveal vulnerabilities)
- **content-type** - Tipe konten (html, json, xml, dll)
- **cache-control** - Kebijakan caching browser
- **x-ua-compatible** - Browser compatibility info
- **content-security-policy** - CSP policy (security)
- **set-cookie** - Session cookies (sensitive!)

### Use Case
- Identifikasi web server type & version
- Cek security headers
- Find sensitive information leaks
- Debug website issues
- Identify potential vulnerabilities

---

## 5️⃣ TOOL: security-check

### Fungsi
Memeriksa apakah website memiliki security headers yang penting.

### Syntax
```bash
.\recon.bat security-check <url>
```

### Parameter
- `<url>` - URL atau domain yang ingin dicek

### Penjelasan
- Mengecek keberadaan 5 security headers penting
- Security headers melindungi dari XSS, clickjacking, MIME sniffing, dll
- Header yang missing = potensi security vulnerability

### Security Headers yang Dicek

1. **Strict-Transport-Security (HSTS)**
   - Memaksa HTTPS connection
   - Melindungi dari downgrade attacks
   - Contoh: `Strict-Transport-Security: max-age=31536000`

2. **X-Frame-Options**
   - Proteksi dari clickjacking attacks
   - Contoh: `X-Frame-Options: DENY` atau `SAMEORIGIN`

3. **X-Content-Type-Options**
   - Proteksi dari MIME sniffing
   - Nilai: `X-Content-Type-Options: nosniff`

4. **Content-Security-Policy (CSP)**
   - Proteksi dari XSS, injection attacks
   - Contoh: `Content-Security-Policy: default-src 'self'`

5. **X-XSS-Protection**
   - Legacy XSS protection (sudah deprecated)
   - Contoh: `X-XSS-Protection: 1; mode=block`

### Contoh: Check google.com
```bash
.\recon.bat security-check google.com
```

Output:
```
[*] Checking security headers...

URL: https://www.google.com/

YES Strict-Transport-Security
NO  X-Frame-Options (MISSING)
YES X-Content-Type-Options
YES Content-Security-Policy
NO  X-XSS-Protection (MISSING)
```

**Penjelasan**:
- ✅ HSTS presence = bagus (enforcing HTTPS)
- ❌ X-Frame-Options missing = website rentan terhadap clickjacking
- ✅ X-Content-Type-Options presence = melindungi dari MIME sniffing
- ✅ CSP presence = bagus (XSS protection)
- ❌ X-XSS-Protection missing = tidak masalah (deprecated, modern browsers punya built-in XSS protection)

### Use Case
- Audit keamanan website
- Identifikasi missing security headers
- Compliance checking (PCI-DSS, OWASP)
- Vulnerability assessment
- Security hardening recommendations

---

## 6️⃣ TOOL: dns-lookup

### Fungsi
Melakukan DNS lookup lengkap untuk domain (A records).

### Syntax
```bash
.\recon.bat dns-lookup <domain>
```

### Parameter
- `<domain>` - Domain yang ingin di-lookup

### Penjelasan
- Mengquery DNS untuk record A (IPv4 addresses)
- Bisa menampilkan multiple IPs jika ada load balancing
- Lebih detail daripada `resolve` tool

### Contoh 1: Lookup google.com
```bash
.\recon.bat dns-lookup google.com
```

Output:
```
[*] DNS Lookup for google.com...

A Records:
  142.251.41.46
  142.251.41.14
  142.251.41.206
  142.251.41.110
```

**Penjelasan**: Google menggunakan multiple servers untuk load balancing

### Contoh 2: Lookup github.com
```bash
.\recon.bat dns-lookup github.com
```

Output:
```
[*] DNS Lookup for github.com...

A Records:
  140.82.113.3
  140.82.114.3
  140.82.115.3
```

### DNS Record Types (Info Tambahan)
Pada version mendatang, tools ini bisa extend untuk:
- **A** = IPv4 address
- **AAAA** = IPv6 address
- **MX** = Mail Exchange servers
- **NS** = Name Servers
- **CNAME** = Canonical Name (alias)
- **TXT** = Text records (SPF, DKIM, DMARC)
- **SOA** = Start of Authority

### Use Case
- Identify all servers for a domain
- Deteksi load balancing/CDN
- DNS reconnaissance
- Find hidden servers/IPs
- Network mapping

---

## 7️⃣ TOOL: ssl-check

### Fungsi
Memeriksa SSL/TLS certificate dari sebuah host.

### Syntax
```bash
.\recon.bat ssl-check <hostname> [port]
```

### Parameter
- `<hostname>` - Target host yang ingin dicek
- `[port]` - (Opsional) Port HTTPS (default: 443)

### Penjelasan
- Mengambil SSL certificate details
- Menampilkan subject, issuer, validity dates
- Mengecek apakah certificate sudah expired
- Warning jika certificate akan expired dalam 30 hari

### Contoh 1: Check google.com
```bash
.\recon.bat ssl-check google.com
```

Output:
```
[*] Checking SSL certificate...

Host: google.com:443
Subject: CN=*.google.com
Issuer: CN=WR2, O=Google Trust Services, C=US
Valid From: 07/21/2026 01:05:56
Valid Until: 10/13/2026 01:05:55
```

**Penjelasan**:
- **Subject** = Domain yang di-cover oleh certificate (*.google.com = wildcard, cover semua subdomain)
- **Issuer** = Certificate Authority yang issue cert
- **Valid From/Until** = Periode validitas certificate
- **Status** = Not expired ✅

### Contoh 2: Check dengan certificate expired soon
```bash
.\recon.bat ssl-check example.com
```

Output:
```
[*] Checking SSL certificate...

Host: example.com:443
Subject: CN=example.com
Issuer: CN=Let's Encrypt Authority X3, ...
Valid From: 06/15/2024 00:00:00
Valid Until: 09/13/2024 23:59:59
WARNING: Certificate expires in 30 days
```

**Penjelasan**: Certificate akan expired dalam 30 hari, perlu renewal segera!

### Contoh 3: Check dengan custom port
```bash
.\recon.bat ssl-check myserver.local 8443
```

**Penjelasan**: Mengecek port 8443 instead of default 443

### Certificate Information

- **CN (Common Name)** = Domain utama
- **Wildcard (*.domain.com)** = Cover semua subdomain
- **Subject Alternative Names** = Domains lain yang di-cover
- **Issuer** = CA yang issue certificate
- **Validity Period** = Waktu certificate valid
- **Key Size** = Strength of encryption

### Use Case
- Monitoring certificate expiry
- Security audit (certificate chain)
- Identify self-signed certificates
- Compliance checking
- Find certificate mismatches
- Vulnerability assessment (outdated certs)

---

## 🎯 QUICK REFERENCE TABLE

| Tool | Command | Target | Optional | Output |
|------|---------|--------|----------|--------|
| public-ip | `public-ip` | None | No | IP address |
| resolve | `resolve` | hostname | No | IP address(es) |
| port-scan | `port-scan` | host | ports | Port status |
| http-headers | `http-headers` | URL | No | HTTP headers |
| security-check | `security-check` | URL | No | Security headers status |
| dns-lookup | `dns-lookup` | domain | No | A records |
| ssl-check | `ssl-check` | host | port | Certificate details |

---

## 💡 TIPS & TRICKS

### 1. Scan Multiple Ports Quickly
```bash
.\recon.bat port-scan target.com 80,443,22,3306,8080
```

### 2. Quick Website Security Audit
```bash
.\recon.bat resolve target.com
.\recon.bat port-scan target.com 80,443
.\recon.bat http-headers target.com
.\recon.bat security-check target.com
.\recon.bat ssl-check target.com
```

### 3. Reconnaissance Pipeline
```bash
.\recon.bat public-ip
.\recon.bat resolve target.com
.\recon.bat dns-lookup target.com
.\recon.bat port-scan target.com
.\recon.bat ssl-check target.com
```

### 4. Check Internal Server on Custom Port
```bash
.\recon.bat ssl-check 192.168.1.100 8443
```

---

## ⚠️ LEGAL & ETHICAL NOTES

✅ **Gunakan untuk:**
- Audit internal
- Learning & education
- Website yang kamu kelola
- Authorized penetration testing
- Internal network reconnaissance

❌ **JANGAN gunakan untuk:**
- Unauthorized network scanning
- Hacking atau akses tidak sah
- Denial of Service
- Target tanpa izin
- Aktivitas ilegal

---

## 📝 CONTOH COMPLETE WORKFLOW

### Scenario: Audit Website Security

```bash
# 1. Resolve domain
.\recon.bat resolve target.com

# Output:
# Host: target.com
#   192.168.1.50

# 2. Scan common ports
.\recon.bat port-scan target.com 80,443,22,3306

# Output:
#   22 : closed [SSH]
#   80 : OPEN   [HTTP]
#   443 : OPEN   [HTTPS]
#   3306 : closed [MySQL]

# 3. Check HTTP headers
.\recon.bat http-headers target.com

# Output:
# server : Apache/2.4.41
# content-type : text/html; charset=UTF-8

# 4. Security audit
.\recon.bat security-check target.com

# Output:
# YES Strict-Transport-Security
# NO  X-Frame-Options (MISSING)
# YES X-Content-Type-Options

# 5. Certificate check
.\recon.bat ssl-check target.com

# Output:
# Subject: CN=target.com
# Valid Until: 10/13/2024 23:59:59
```

**Hasil Audit:**
- ✅ Website accessible on HTTP & HTTPS
- ⚠️ Missing X-Frame-Options header (vulnerable to clickjacking)
- ✅ Has HSTS enabled
- ✅ Certificate valid until October 2024

---

Semua tools siap digunakan! Pilih tools yang sesuai dengan kebutuhan kamu. 🚀
