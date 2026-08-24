# 🎯 SEMUA TOOLS + CONTOH REAL OUTPUT

## TOOL #1: PUBLIC-IP - Get Your Public IP

**Command:**
```bash
.\recon.bat public-ip
```

**Output (Real):**
```
[*] Fetching public IP...
Public IP: 103.116.49.137
```

**Penjelasan:**
- Menampilkan IP publik kamu dari perspektif internet
- Tidak memerlukan parameter tambahan
- Berguna untuk debugging network connectivity

---

## TOOL #2: RESOLVE - DNS Resolution (Hostname to IP)

**Command:**
```bash
.\recon.bat resolve google.com
```

**Output (Real):**
```
[*] Resolving google.com...
Host: google.com
  216.239.38.120
```

**Penjelasan:**
- Convert hostname menjadi IP address
- Melakukan DNS query
- Bisa punya multiple IPs untuk load balancing

---

## TOOL #3: PORT-SCAN - Check Open Ports

**Command 1 - Specific Ports:**
```bash
.\recon.bat port-scan google.com 21,22,80,443,3306
```

**Output (Real):**
```
[*] Scanning google.com...

  21 : closed [FTP]
  22 : closed [SSH]
  80 : OPEN   [HTTP]
  443 : OPEN   [HTTPS]
  3306 : closed [MySQL]
```

**Penjelasan Output:**
- Port 80 & 443 = OPEN (Web server aktif)
- Port 21, 22, 3306 = CLOSED (Tidak ada service)
- Timeout per port: 1000ms
- [FTP], [SSH], [HTTPS], [MySQL] = Service name

**Command 2 - Scan Semua Port Umum:**
```bash
.\recon.bat port-scan google.com
```
(Akan scan 25 port umum secara default)

---

## TOOL #4: HTTP-HEADERS - Get HTTP Response Headers

**Command:**
```bash
.\recon.bat http-headers google.com
```

**Output (Real Sample):**
```
[*] Fetching headers from https://google.com...

URL: https://www.google.com/

Content-Security-Policy-Report-Only : object-src 'none';base-uri 'self';script-src 'nonce-tAvfL4073B5vkjacDrdmKw' ...
Accept-CH : Sec-CH-Prefers-Color-Scheme
X-XSS-Protection : 0
X-Frame-Options : SAMEORIGIN
Cache-Control : private, max-age=0
Content-Type : text/html; charset=UTF-8
Date : Sat, 15 Aug 2026 23:16:46 GMT
Expires : -1
P3P : CP="This is not a P3P policy! See g.co/p3phelp for more info."
Set-Cookie : __Secure-STRP=ANmZwa04_OEl4OwDuVShBMYyX01b5ZuClrZLZFGU1HV_...
Server : gws
Alt-Svc : h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
Accept-Ranges : none
Vary : Accept-Encoding
Transfer-Encoding : chunked
```

**Penjelasan Penting:**
- **Server: gws** = Web server type (Google Web Server)
- **Content-Type** = Response format (text/html)
- **Cache-Control** = Caching policy
- **X-Frame-Options: SAMEORIGIN** = Clickjacking protection
- **Set-Cookie** = Session cookies (sensitive!)
- **Content-Security-Policy** = XSS protection

---

## TOOL #5: SECURITY-CHECK - Verify Security Headers

**Command:**
```bash
.\recon.bat security-check google.com
```

**Output (Real):**
```
[*] Checking security headers...

URL: https://www.google.com/

NO  Strict-Transport-Security (MISSING)
YES X-Frame-Options
NO  X-Content-Type-Options (MISSING)
NO  Content-Security-Policy (MISSING)
YES X-XSS-Protection
```

**Penjelasan:**
```
Headers dicek:
1. Strict-Transport-Security    ❌ MISSING
   - Fungsi: Enforce HTTPS connection
   - Risk: Downgrade attacks, MITM

2. X-Frame-Options              ✅ PRESENT (SAMEORIGIN)
   - Fungsi: Prevent clickjacking
   - Status: GOOD

3. X-Content-Type-Options       ❌ MISSING
   - Fungsi: Prevent MIME sniffing
   - Risk: MIME type confusion attacks

4. Content-Security-Policy      ❌ MISSING
   - Fungsi: Restrict content sources
   - Risk: XSS attacks

5. X-XSS-Protection             ✅ PRESENT
   - Fungsi: Legacy XSS protection
   - Status: OK (but deprecated)
```

**Hasil Audit Google:**
- ⚠️ Missing 3 important security headers
- ✅ Has 2 security headers present
- Score: 40% (2/5 headers)

---

## TOOL #6: DNS-LOOKUP - Full DNS Resolution

**Command:**
```bash
.\recon.bat dns-lookup google.com
```

**Output (Real):**
```
[*] DNS Lookup for google.com...

A Records:
  216.239.38.120
```

**Penjelasan:**
- A Record = IPv4 address untuk domain
- Bisa punya multiple IPs (load balancing, CDN)
- Lebih detail daripada `resolve` tool

---

## TOOL #7: SSL-CHECK - Certificate Information

**Command:**
```bash
.\recon.bat ssl-check google.com
```

**Output (Real):**
```
[*] Checking SSL certificate...

Host: google.com:443
Subject: CN=*.google.com
Issuer: CN=WR2, O=Google Trust Services, C=US
Valid From: 07/21/2026 01:05:56
Valid Until: 10/13/2026 01:05:55
```

**Penjelasan Detail:**
- **Host: google.com:443** = Target dan port (443 = HTTPS default)
- **Subject: CN=*.google.com** = Domain covered (* = wildcard untuk semua subdomain)
- **Issuer: CN=WR2, O=Google Trust Services** = Certificate Authority
- **Valid From/Until** = Periode validitas certificate
- ✅ Status: Certificate VALID (not expired)

**Contoh dengan Custom Port:**
```bash
.\recon.bat ssl-check myserver.local 8443
```

---

## 🎯 QUICK COMMAND REFERENCE

| # | Tool | Command | Output |
|---|------|---------|--------|
| 1 | public-ip | `.\recon.bat public-ip` | Your public IP |
| 2 | resolve | `.\recon.bat resolve google.com` | IP addresses |
| 3 | port-scan | `.\recon.bat port-scan target.com 80,443` | Port status |
| 4 | http-headers | `.\recon.bat http-headers google.com` | HTTP headers |
| 5 | security-check | `.\recon.bat security-check google.com` | Security headers status |
| 6 | dns-lookup | `.\recon.bat dns-lookup google.com` | A records |
| 7 | ssl-check | `.\recon.bat ssl-check google.com` | Certificate info |

---

## 💡 COMMON USAGE SCENARIOS

### Scenario 1: Quick Website Security Audit
```bash
# 1. Resolve domain
.\recon.bat resolve mywebsite.com

# 2. Check ports
.\recon.bat port-scan mywebsite.com 80,443

# 3. Get headers
.\recon.bat http-headers mywebsite.com

# 4. Security audit
.\recon.bat security-check mywebsite.com

# 5. Certificate check
.\recon.bat ssl-check mywebsite.com
```

### Scenario 2: Know Your Network
```bash
# Check your public IP
.\recon.bat public-ip

# Find server IPs
.\recon.bat resolve server1.com
.\recon.bat resolve server2.com
.\recon.bat resolve server3.com

# DNS lookup
.\recon.bat dns-lookup company.com

# Port scanning
.\recon.bat port-scan 192.168.1.1 22,80,443
```

### Scenario 3: Certificate Management
```bash
# Check domain certificate
.\recon.bat ssl-check domain.com

# Check internal server
.\recon.bat ssl-check 192.168.1.100 8443

# Get all certificate details
.\recon.bat http-headers domain.com
.\recon.bat ssl-check domain.com
.\recon.bat security-check domain.com
```

---

## 📊 PORT REFERENCE

```
Common Web Ports:
  80    = HTTP (unencrypted web)
  443   = HTTPS (encrypted web)
  8080  = HTTP Alternative
  8443  = HTTPS Alternative

Email Ports:
  25    = SMTP (send mail)
  110   = POP3 (receive mail)
  143   = IMAP (receive mail)
  465   = SMTPS (secure send)
  587   = SMTP Submission
  993   = IMAPS (secure receive)
  995   = POP3S (secure receive)

Remote Access:
  22    = SSH (secure shell)
  23    = Telnet (insecure remote)
  3389  = RDP (Remote Desktop Protocol)

DNS & Network:
  53    = DNS (domain names)

Database Ports:
  1433  = MSSQL (Microsoft SQL Server)
  1521  = Oracle Database
  3306  = MySQL
  5432  = PostgreSQL

Search/Data:
  9200  = Elasticsearch
  27017 = MongoDB

Other:
  21    = FTP (file transfer)
  111   = RPC (Remote Procedure Call)
  135   = RPC Endpoint
  139   = NetBIOS
```

---

## ✅ VERIFICATION - ALL TOOLS TESTED

Semua tools telah ditest dan bekerja dengan sempurna:

✅ **public-ip** - Output: 103.116.49.137
✅ **resolve** - Output: google.com → 216.239.38.120
✅ **port-scan** - Output: Port 80 & 443 OPEN
✅ **http-headers** - Output: 15+ HTTP headers retrieved
✅ **security-check** - Output: 2/5 security headers present
✅ **dns-lookup** - Output: A record retrieved
✅ **ssl-check** - Output: Certificate valid until 10/13/2026

---

## 📚 AVAILABLE DOCUMENTATION

1. **README.md** - Project overview & setup
2. **QUICK_START.md** - Quick examples & common usage
3. **TOOLS_GUIDE.md** - Detailed explanation setiap tool
4. **RINGKASAN_TOOLS.md** - Tool summary
5. **ALL_TOOLS_EXAMPLES.md** - File ini (contoh real output)

---

## 🎉 READY TO USE!

Semua 7 tools siap digunakan. Pilih tools yang sesuai kebutuhan kamu!

**Start with:**
```bash
.\recon.bat help
.\recon.bat public-ip
.\recon.bat resolve google.com
.\recon.bat port-scan google.com 80,443
```

Selamat menggunakan! 🚀
