# QUICK START - SECURITY RECON CLI

## 🎯 7 TOOLS UTAMA - CONTOH & PENJELASAN

### 1️⃣ PUBLIC-IP
**Tampilkan IP publik kamu**

```bash
.\recon.bat public-ip
```

**Output:**
```
[*] Fetching public IP...
Public IP: 103.116.49.137
```

**Penjelasan:**
- Menampilkan IP address kamu dari perspektif internet
- Berguna untuk debugging koneksi network

---

### 2️⃣ RESOLVE
**Convert hostname/domain menjadi IP address**

```bash
.\recon.bat resolve google.com
```

**Output:**
```
[*] Resolving google.com...
Host: google.com
  216.239.38.120
```

**Penjelasan:**
- Melakukan DNS resolution
- Satu domain bisa punya multiple IPs (load balancing)
- Bisa detect domain tidak valid

---

### 3️⃣ PORT-SCAN
**Scan port pada host untuk cek status (open/closed)**

```bash
.\recon.bat port-scan google.com 21,22,80,443,3306
```

**Output:**
```
[*] Scanning google.com...

  21 : closed [FTP]
  22 : closed [SSH]
  80 : OPEN   [HTTP]
  443 : OPEN   [HTTPS]
  3306 : closed [MySQL]
```

**Penjelasan:**
- Port OPEN = Service aktif
- Port closed = Tidak ada service atau firewall block
- Timeout per port: 1000ms
- Scan semua port umum: `.\recon.bat port-scan google.com`

**Common Ports:**
```
21   = FTP        53  = DNS       443 = HTTPS    3306 = MySQL
22   = SSH        80  = HTTP      465 = SMTPS    8080 = Alt HTTP
25   = SMTP       110 = POP3      993 = IMAPS    9200 = Elasticsearch
```

---

### 4️⃣ HTTP-HEADERS
**Ambil HTTP response headers dari website**

```bash
.\recon.bat http-headers google.com
```

**Output (sample):**
```
URL: https://www.google.com/

Content-Security-Policy-Report-Only : ...
X-XSS-Protection : 0
X-Frame-Options : SAMEORIGIN
Cache-Control : private, max-age=0
Content-Type : text/html; charset=UTF-8
Date : Sat, 15 Aug 2026 23:16:46 GMT
Server : gws
```

**Penjelasan:**
- **server** = Jenis web server (bisa reveal vulnerabilities)
- **Content-Type** = Format konten (html, json, xml, dll)
- **Set-Cookie** = Session cookies (sensitive info!)
- **Cache-Control** = Browser caching policy
- Bisa detect server type & version

---

### 5️⃣ SECURITY-CHECK
**Periksa apakah website punya security headers penting**

```bash
.\recon.bat security-check google.com
```

**Output:**
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
- ✅ YES = Header present (bagus)
- ❌ NO = Header missing (potential vulnerability)

**Security Headers yang dicek:**

| Header | Fungsi | Proteksi Dari |
|--------|--------|---------------|
| **Strict-Transport-Security** | Enforce HTTPS | Downgrade attacks, Man-in-middle |
| **X-Frame-Options** | Block framing | Clickjacking attacks |
| **X-Content-Type-Options** | Block MIME sniffing | MIME type confusion attacks |
| **Content-Security-Policy** | Restrict content source | XSS, injection attacks |
| **X-XSS-Protection** | Legacy XSS protection | Old XSS attacks |

---

### 6️⃣ DNS-LOOKUP
**Melakukan DNS lookup lengkap untuk domain**

```bash
.\recon.bat dns-lookup google.com
```

**Output:**
```
[*] DNS Lookup for google.com...

A Records:
  216.239.38.120
```

**Penjelasan:**
- A Record = IPv4 address untuk domain
- Bisa multiple IPs untuk load balancing
- Lebih detail daripada `resolve` tool

---

### 7️⃣ SSL-CHECK
**Periksa SSL/TLS certificate details**

```bash
.\recon.bat ssl-check google.com
```

**Output:**
```
[*] Checking SSL certificate...

Host: google.com:443
Subject: CN=*.google.com
Issuer: CN=WR2, O=Google Trust Services, C=US
Valid From: 07/21/2026 01:05:56
Valid Until: 10/13/2026 01:05:55
```

**Penjelasan:**
- **Subject** = Domain yang di-cover (*.google.com = wildcard)
- **Issuer** = Certificate Authority
- **Valid From/Until** = Validity period
- Warning jika certificate akan expired dalam 30 hari
- Bisa specify port: `.\recon.bat ssl-check myserver.local 8443`

---

## 🚀 USAGE EXAMPLES

### Example 1: Quick Website Audit
```bash
.\recon.bat resolve example.com
.\recon.bat port-scan example.com 80,443
.\recon.bat http-headers example.com
.\recon.bat security-check example.com
.\recon.bat ssl-check example.com
```

### Example 2: Full Reconnaissance
```bash
.\recon.bat public-ip
.\recon.bat resolve target.com
.\recon.bat dns-lookup target.com
.\recon.bat port-scan target.com
.\recon.bat ssl-check target.com
.\recon.bat http-headers target.com
.\recon.bat security-check target.com
```

### Example 3: Port Scanning
```bash
# Scan default ports
.\recon.bat port-scan 8.8.8.8

# Scan specific ports
.\recon.bat port-scan 192.168.1.1 22,80,443,3306,5432

# Scan web servers
.\recon.bat port-scan target.com 80,443,8080,8443
```

---

## 📊 COMPARISON TABLE

| Tool | Input | Output | Use Case |
|------|-------|--------|----------|
| `public-ip` | None | IP address | Know your public IP |
| `resolve` | hostname | IP address | DNS resolution |
| `port-scan` | host + ports | Port status | Identify open services |
| `http-headers` | URL | HTTP headers | Find server info |
| `security-check` | URL | Security headers status | Audit website security |
| `dns-lookup` | domain | A records | DNS reconnaissance |
| `ssl-check` | host + port | Certificate info | Check SSL status |

---

## 💡 TIPS

1. **Scan Multiple Ports Faster**
   ```bash
   .\recon.bat port-scan target.com 80,443,22,3306,8080,9200
   ```

2. **Check Custom Port for SSL**
   ```bash
   .\recon.bat ssl-check 192.168.1.100 8443
   ```

3. **Automate Security Audit**
   ```bash
   # Save all results
   .\recon.bat resolve example.com > results.txt
   .\recon.bat port-scan example.com >> results.txt
   .\recon.bat security-check example.com >> results.txt
   ```

4. **Check Internal Server**
   ```bash
   .\recon.bat port-scan 192.168.1.1 22,80,443,3306
   .\recon.bat ssl-check 192.168.1.1 8443
   ```

---

## ⚖️ ETHICAL USAGE

✅ **OK untuk digunakan:**
- Audit website milik sendiri
- Learning & education
- Authorized penetration testing
- Internal network assessment

❌ **JANGAN gunakan untuk:**
- Unauthorized network scanning
- Hacking atau akses tidak sah
- Target tanpa izin
- Denial of Service

---

## 📝 DOCUMENTATION

- **Full Guide**: TOOLS_GUIDE.md (detailed explanation setiap tool)
- **README**: README.md (project overview & installation)

---

Semua tools siap digunakan! Pilih yang sesuai kebutuhan. 🎯
