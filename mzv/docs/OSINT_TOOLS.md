# OSINT Tools Documentation

Dokumentasi lengkap untuk 8 tools OSINT baru yang ditambahkan ke Security Recon CLI.

## 📊 Daftar Tools OSINT

1. **Have I Been Pwned (breach)** - Email breach checker
2. **WHOIS** - Domain registration information
3. **Google Dorks** - Search operator generator
4. **Shodan** - IoT/Server search engine
5. **Censys** - Certificate search
6. **Email Enumeration** - Common email pattern generator
7. **Username Checker** - Cross-platform username lookup
8. **Extended DNS Enumeration** - Advanced DNS record lookup

---

## 1. Have I Been Pwned (HIBP)

### Fungsi
Memeriksa apakah email telah ditemukan dalam data breach publik.

### Syntax
```powershell
.\cli.ps1 breach user@example.com
.\recon.bat breach admin@company.com
```

### Contoh Output - Email TIDAK dalam breach:
```
Checking Have I Been Pwned for: user@example.com...

OK: Email NOT found in any known breaches
```

### Contoh Output - Email DITEMUKAN dalam breach:
```
Checking Have I Been Pwned for: john@example.com...

WARNING: EMAIL FOUND IN BREACHES!

Breach: Adobe
  Date: 2013-10-04
  Title: Adobe had 153 million user accounts stolen
  
Breach: LinkedIn
  Date: 2012-05-05
  Title: LinkedIn suffered a massive data breach
```

### Kegunaan
- Memverifikasi apakah email telah dikompromikan
- Melakukan security audit untuk organisasi
- Monitoring email addresses untuk breach baru
- Incident response dan forensics

### API Information
- **Service**: haveibeenpwned.com (FREE)
- **Rate Limit**: 1 request per 1.5 seconds
- **Akses**: Public API, tidak perlu API key
- **Data**: Updated regularly dengan breach baru

### Important Notes
- Data dari HIBP bersifat publik dan sering digunakan oleh threat actors
- Jika email ditemukan, segera ubah password
- Pastikan menggunakan unique password di setiap website

---

## 2. WHOIS Lookup

### Fungsi
Mengambil informasi registrasi domain dari WHOIS server.

### Syntax
```powershell
.\cli.ps1 whois example.com
.\recon.bat whois google.com
```

### Contoh Output - Dengan whois command installed:
```
Fetching WHOIS information for: example.com...

Domain Name: EXAMPLE.COM
Registry Domain ID: D102371394-AGRS
Registrar WHOIS Server: whois.verisign-grs.com
Admin Name: John Doe
Admin Email: admin@example.com
Tech Name: Tech Support
Creation Date: 1995-08-14
Expiration Date: 2025-08-13
Registrar: VeriSign Global Registry Services
```

### Contoh Output - Tanpa whois command:
```
Fetching WHOIS information for: example.com...

Domain: example.com
IP Address: 93.184.216.34

Note: Install whois command for full WHOIS details
Windows: choco install whois
```

### Setup Windows WHOIS Command
```powershell
# Install via Chocolatey
choco install whois

# Verify installation
whois example.com
```

### Kegunaan
- Mengidentifikasi pemilik domain
- Menemukan informasi kontak admin/tech
- Checking domain registration dates
- Mendeteksi domain typosquatting
- Investigating phishing domains

### WHOIS Fields
- **Domain Name**: Nama domain yang terdaftar
- **Registrar**: Perusahaan penyedia layanan
- **Admin Contact**: Informasi administrator domain
- **Tech Contact**: Informasi technical contact
- **Name Servers**: DNS servers yang digunakan
- **Creation Date**: Tanggal pembuatan domain
- **Expiration Date**: Tanggal kadaluarsa domain

### Notes
- WHOIS data bisa di-private via privacy services
- Private WHOIS = informasi tersembunyi
- Beberapa registrar menyembunyikan informasi secara default

---

## 3. Google Dorks

### Fungsi
Menghasilkan advanced Google search queries untuk reconnaissance.

### Syntax
```powershell
.\cli.ps1 google-dorks example.com
.\recon.bat google-dorks company.org
```

### Contoh Output:
```
Generating Google Dorks for: example.com

GOOGLE DORKS FOR: example.com
=================================

1. site:example.com
2. site:example.com filetype:pdf
3. site:example.com filetype:xls
4. site:example.com filetype:doc
5. site:example.com admin OR login
6. site:example.com password OR pass
7. site:example.com confidential OR secret
8. site:example.com inurl:admin
9. site:example.com inurl:login
10. site:example.com inurl:api
11. site:example.com cache:
12. site:example.com SQL error
13. site:example.com mysql_fetch
14. site:example.com intitle:index.of
15. site:example.com ext:config OR ext:xml OR ext:json

Use these dorks in Google Search to find:
  - Exposed files and documents
  - Admin panels and login pages
  - Configuration files
```

### Kegunaan
- Menemukan exposed files dan documents
- Locating admin panels dan login pages
- Finding configuration files
- Detecting SQL errors (SQLi indicators)
- Searching API endpoints
- Cache searching untuk informasi kadaluarsa

### Dork Types Penjelasan

| Dork | Kegunaan |
|------|----------|
| `site:` | Limit results ke domain tertentu |
| `filetype:` | Search specific file types |
| `inurl:` | Search dalam URL |
| `intitle:` | Search dalam page title |
| `cache:` | Google cached version |
| `OR` / `AND` | Logical operators |
| `"exact phrase"` | Exact match searching |

### Contoh Advanced Dorks
```
site:example.com filetype:sql
site:example.com "admin" "password"
site:example.com intitle:"login" OR intitle:"admin"
site:example.com ext:conf OR ext:config
```

### Ethical Considerations
- Google Dorks adalah legal reconnaissance technique
- Digunakan untuk security auditing dan penetration testing
- Jangan gunakan untuk unauthorized access
- Selalu dapatkan permission terlebih dahulu

---

## 4. Shodan Search

### Fungsi
Mencari devices, servers, dan IoT devices yang terhubung ke internet.

### Syntax
```powershell
.\cli.ps1 shodan "nginx"
.\cli.ps1 shodan "apache" [API_KEY]
.\recon.bat shodan "mongodb"
```

### Setup API Key

```powershell
# 1. Create account di https://www.shodan.io/
# 2. Go to Account > API Key

# Set environment variable
$env:SHODAN_API_KEY = "your-api-key-here"

# Verify
echo $env:SHODAN_API_KEY
```

### Contoh Output:
```
Searching Shodan for: nginx

Found 2500000 results

IP: 103.145.23.45
  Port: 80
  Org: PT Telekomunikasi
  Title: Welcome to nginx!

IP: 192.168.1.100
  Port: 8080
  Org: XYZ Company
  Title: Admin Dashboard

...more results...
```

### Kegunaan
- Menemukan services yang exposed
- Identifying vulnerable server versions
- Finding IoT devices dengan authentication lemah
- Geolocation-based searching
- Detecting default credentials
- Finding webcams, routers, databases yang exposed

### Search Queries Contoh

| Query | Kegunaan |
|-------|----------|
| `nginx` | Find nginx servers |
| `apache` | Find apache servers |
| `mongodb default` | MongoDB dengan default config |
| `mysql -root -password` | MySQL tanpa password |
| `webcam` | Internet-connected webcams |
| `router netgear` | Netgear routers |
| `raspberry pi` | Raspberry Pi devices |

### Important Security Notes
- Shodan mengindeks public-facing services
- Jangan scan/attack devices tanpa permission
- Gunakan hanya untuk authorized assessment
- Respect Robots.txt dan legal boundaries

### Pricing
- **Free Plan**: 1 query + limited results
- **Professional**: $49/month untuk 10,000 queries
- **API Credits**: Available untuk large scans

---

## 5. Censys Certificate Search

### Fungsi
Mencari dan menganalisis SSL/TLS certificates di internet.

### Syntax
```powershell
.\cli.ps1 censys "example.com"
.\cli.ps1 censys "google.com" [USER_ID]
.\recon.bat censys "*.example.com"
```

### Setup Credentials

```powershell
# 1. Create account di https://censys.io/
# 2. Go to Account > API

# Set environment variables
$env:CENSYS_USER_ID = "your-user-id"
$env:CENSYS_API_SECRET = "your-api-secret"

# Verify
echo $env:CENSYS_USER_ID
echo $env:CENSYS_API_SECRET
```

### Contoh Output:
```
Searching Censys for: example.com

Found 42 certificates

SHA-256: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6...
  Names: *.example.com, example.com
  Validity: true

SHA-256: b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7...
  Names: mail.example.com, www.example.com
  
...more results...
```

### Kegunaan
- Menemukan subdomains melalui certificate names
- Detecting certificate misuse
- Finding expired certificates
- Identifying domain ownership changes
- Certificate transparency monitoring
- Supply chain reconnaissance

### Certificate Fields
- **SHA-256**: Certificate fingerprint
- **Names**: Subject Alternative Names (SANs)
- **Validity**: Certificate validity status
- **Issuer**: Certificate authority
- **Dates**: Issue dan expiration dates

### Advanced Searches
```
query: "example.com"
query: "*.example.com OR *.mail.example.com"
query: "example.com AND NOT staging"
```

### Benefits
- **Subdomains**: Certificates reveal hidden subdomains
- **Infrastructure Mapping**: Understand company structure
- **SSL Changes**: Detect infrastructure changes
- **Duplicate Certs**: Find replicated infrastructure

### Ethical Use
- Certificate data adalah public
- Digunakan untuk security research
- Legitimate reconnaissance untuk authorized assessments
- Part of standard offensive security methodology

---

## 6. Email Enumeration

### Fungsi
Menghasilkan daftar email pattern umum untuk domain target.

### Syntax
```powershell
.\cli.ps1 email-enum example.com
.\cli.ps1 email-enum google.com
.\recon.bat email-enum company.org
```

### Contoh Output:
```
Enumerating email patterns for: example.com

COMMON EMAIL PATTERNS:
=====================

admin@example.com
support@example.com
info@example.com
contact@example.com
sales@example.com
marketing@example.com
hr@example.com
accounts@example.com
billing@example.com
noreply@example.com
hello@example.com
help@example.com
abuse@example.com
security@example.com
```

### Kegunaan
- Crafting spear-phishing campaigns
- Social engineering reconnaissance
- Finding valid email addresses
- Building target contact lists
- Verifying email existence (dengan tools lain)
- HR/organizational structure identification

### Email Pattern Tipe

| Pattern | Deskripsi |
|---------|-----------|
| `admin@` | Administrator mailbox |
| `support@` | Customer support |
| `info@` | General information |
| `sales@` | Sales team |
| `security@` | Security contact |
| `abuse@` | Abuse/complaint reporting |
| `noreply@` | Automated emails |

### Advanced Email Discovery Tools
Tools yang lebih powerful untuk email enumeration:

1. **theHarvester** (Python)
   ```bash
   pip install theharvester
   theharvester -d example.com -b all
   ```

2. **Hunter.io** (Web Service)
   - https://hunter.io/
   - Find all email addresses dari domain
   - Email verification

3. **RocketReach** (Web Service)
   - Professional contact database
   - Phone numbers dan emails
   - Job titles dan company info

### Email Verification
Setelah mendapat email list, verify dengan:
- `mail-tester.com` untuk format validation
- SMTP verification (risky - bisa terdeteksi)
- Third-party email verification services

---

## 7. Username Checker

### Fungsi
Mencari username di platform media sosial dan website populer.

### Syntax
```powershell
.\cli.ps1 username-check john
.\cli.ps1 username-check john_doe
.\recon.bat username-check admin
```

### Contoh Output:
```
Checking username: john

CHECKING USERNAME:
==================

OK GitHub
OK Twitter
OK Instagram
NO LinkedIn
OK Reddit
OK YouTube
```

### Kegunaan
- Social media reconnaissance
- Identifying target personas
- Finding personal profiles
- OSINT untuk targeted campaigns
- Verifying username availability
- Cross-platform account linking

### Platform yang Dicek
- GitHub (Developer profiles)
- Twitter (Social updates)
- Instagram (Personal photos)
- LinkedIn (Professional info)
- Reddit (Anonymous discussions)
- YouTube (Video content)

### Advanced Username Discovery
Tool lebih comprehensive untuk username lookup:

**Sherlock Project** (Recommended)
```bash
pip install sherlock-project
sherlock username

# Extensive platform checking
# Fast parallel scanning
# JSON output format
```

### OSINT Applications
- **Employee Profiling**: Finding employee personal profiles
- **Target Identification**: Linking employees to social accounts
- **Vulnerability Research**: Finding developers dengan public PoC
- **Threat Intelligence**: Tracking threat actors across platforms

### Privacy Considerations
- Usernames bisa membuka informasi pribadi
- Cross-platform linking dapat membuat profile lengkap
- Kombinasi dengan HIBP = powerful doxing tool
- Always use untuk authorized purposes only

---

## 8. Extended DNS Enumeration

### Fungsi
Melakukan comprehensive DNS record lookup dan analysis.

### Syntax
```powershell
.\cli.ps1 dns-enum example.com
.\recon.bat dns-enum google.com
```

### Contoh Output:
```
Extended DNS enumeration for: example.com

A Records:
  93.184.216.34
  93.184.216.35

MX Records (Mail Servers):
  example.com   MX preference = 10, mail exchanger = mail1.example.com
  example.com   MX preference = 20, mail exchanger = mail2.example.com

NS Records (Nameservers):
  example.com   nameserver = ns1.example.com
  example.com   nameserver = ns2.example.com
  example.com   nameserver = ns3.example.com
```

### DNS Record Types

| Type | Kegunaan |
|------|----------|
| **A** | IPv4 address mapping |
| **AAAA** | IPv6 address mapping |
| **MX** | Mail server information |
| **NS** | Nameserver delegation |
| **CNAME** | Canonical name (aliases) |
| **TXT** | Text records (SPF, DKIM, DMARC) |
| **SOA** | Start of authority |
| **SRV** | Service records |

### Kegunaan
- Email infrastructure mapping
- Nameserver identification
- Mail server identification
- SPF/DKIM/DMARC policy checking
- DNS configuration reconnaissance
- Subdomain enumeration (via DNS wildcards)
- Detecting virtual hosting (CNAME analysis)

### Advanced DNS Tools

**nslookup** (Built-in)
```powershell
nslookup example.com
nslookup -type=MX example.com
nslookup -type=TXT example.com
```

**dig** (Linux/WSL)
```bash
dig example.com
dig example.com MX
dig example.com TXT
dig @8.8.8.8 example.com  # Use specific nameserver
```

**dnsenum** (Advanced)
```bash
pip install dnsenum
dnsenum example.com
```

### Email Security Records

**SPF (Sender Policy Framework)**
```dns
v=spf1 include:_spf.google.com ~all
```
- Prevents email spoofing
- Authorizes mail servers

**DKIM (DomainKeys Identified Mail)**
```dns
v=DKIM1; k=rsa; p=MIGfMA0GCSq...
```
- Email authentication
- Digital signatures

**DMARC (Domain-based Message Authentication)**
```dns
v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com
```
- Policy enforcement
- Reporting

### Security Implications
- DNS records harus dikonfigurasi dengan benar
- Email headers dapat di-spoof tanpa SPF/DKIM/DMARC
- DNS poisoning risk jika NS dikompromikan
- DNS can reveal infrastructure topology

---

## 🔗 Comparison dengan Tools Lain

### Equivalent Professional Tools
```
CLI Tool                External Tool / Service
========================================
breach              → Have I Been Pwned API
whois               → whois.com, registrar APIs
google-dorks        → Google.com, Shodan, Censys
shodan              → Shodan.io (native)
censys              → Censys.io (native)
email-enum          → Hunter.io, RocketReach
username-check      → Sherlock, Maigret
dns-enum            → DNSenum, Sublist3r, Massdns
```

---

## 📋 Workflow Contoh

### Reconnaissance Komprehensif untuk example.com

```powershell
# 1. Get basic information
.\cli.ps1 whois example.com

# 2. DNS enumeration
.\cli.ps1 dns-enum example.com

# 3. Email reconnaissance
.\cli.ps1 email-enum example.com

# 4. Google Dorks untuk exposed data
.\cli.ps1 google-dorks example.com

# 5. Advanced searches
.\cli.ps1 shodan "example.com"
.\cli.ps1 censys "*.example.com"

# 6. Check for breaches
.\cli.ps1 breach admin@example.com
.\cli.ps1 breach support@example.com

# 7. Find employees & their accounts
# (Use email-enum + username-check)
.\cli.ps1 username-check john_smith
```

---

## ⚠️ Legal & Ethical Guidelines

### Authorized Use Only
- Lakukan reconnaissance hanya pada domain yang Anda miliki atau dengan explicit written permission
- Penetration testing memerlukan contract dan scope definition yang jelas
- Gunakan tools hanya untuk defensive security purposes

### Responsible Disclosure
- Jika menemukan vulnerability, laporkan ke owner
- Follow responsible disclosure practices
- Give reasonable time untuk patch sebelum public disclosure

### GDPR & Privacy
- Email addresses adalah PII (Personally Identifiable Information)
- GDPR requires proper data handling
- Don't store personal data tanpa consent
- Follow privacy regulations di jurisdiksi Anda

### Terms of Service
- HIBP: Free, educational use
- Shodan: Respect rate limits, paid subscription recommended
- Censys: Free tier dengan limitations
- Google: Don't automated massive queries (use Google API)

---

## 🚀 Tips & Best Practices

1. **Combine Multiple Tools**: Gunakan hasil dari satu tool sebagai input untuk tool lain
2. **Document Findings**: Simpan semua results untuk reporting
3. **Cross-Verify**: Verify critical findings dengan multiple tools
4. **Set Environment Variables**: Store API keys secara secure
5. **Use VPN/Proxy**: Untuk operational security saat melakukan OSINT
6. **Rate Limiting**: Respect API rate limits
7. **Stay Legal**: Always check authorization sebelum testing

---

**Last Updated**: 2026-08-16
**CLI Version**: 2.0
**Tools**: 15 total (7 Recon + 8 OSINT)
