# API Setup Guide

Panduan lengkap untuk setup API keys untuk tools yang memerlukan authentication.

## 📌 Overview

Dari 8 tools OSINT baru, 3 tools memerlukan API keys:
1. **Shodan** - IoT/Server search engine
2. **Censys** - Certificate search
3. **Have I Been Pwned** - Email breach checker (opsional, free API)

---

## 1. Shodan API Setup

### Deskripsi
Shodan adalah search engine untuk internet-connected devices. Digunakan untuk menemukan servers, IoT devices, dan services yang exposed.

### Step 1: Create Shodan Account

1. Buka https://www.shodan.io/
2. Click **"Sign Up"** atau **"Create Account"**
3. Masukkan email dan password
4. Verify email Anda
5. Login ke account

### Step 2: Get API Key

1. Login ke Shodan
2. Click **Account** (top right)
3. Click **"API"** atau **"API Key"**
4. Salin API key Anda (format: alphanumeric string ~40 characters)

### Step 3: Set Environment Variable

#### Option 1: PowerShell Session (Temporary)
```powershell
# Set untuk current session saja
$env:SHODAN_API_KEY = "your-api-key-here"

# Verify
echo $env:SHODAN_API_KEY
```

#### Option 2: Permanent (Windows)
```powershell
# Set permanent environment variable
[Environment]::SetEnvironmentVariable("SHODAN_API_KEY", "your-api-key-here", "User")

# Restart PowerShell
```

Atau via GUI:
1. Press **Win + Pause**
2. Click **Advanced system settings**
3. Click **Environment Variables**
4. Click **New** (User variables)
5. Variable name: `SHODAN_API_KEY`
6. Variable value: `your-api-key`
7. OK > OK

#### Option 3: Via PowerShell Profile
```powershell
# Edit PowerShell profile
notepad $PROFILE

# Add line:
$env:SHODAN_API_KEY = "your-api-key-here"

# Save and reload PowerShell
```

### Step 4: Test

```powershell
cd c:\Users\user\Desktop\mzv
.\recon.bat shodan "nginx"
```

Expected output:
```
Searching Shodan for: nginx
Found 2500000 results
IP: xxx.xxx.xxx.xxx
  Port: 80
  ...
```

### Shodan Pricing

| Plan | Price | Queries/Month | Concurrent |
|------|-------|---------------|-----------|
| Free | $0 | 1 search | Limited |
| Basic | $49 | 10,000 | 10 |
| Pro | $299 | 100,000 | 50 |
| Corporate | Custom | Custom | Custom |

### Tips
- Free tier hanya 1 query dengan limited results
- **Recommended**: Use free tier untuk testing, upgrade untuk production
- Queries are counted per month
- Save interesting searches untuk reference

### Example Queries
```
nginx
apache 2.4
mongodb
mysql default
webcam
router netgear
```

---

## 2. Censys API Setup

### Deskripsi
Censys adalah platform untuk certificate, IP, dan domain data. Useful untuk finding subdomains via certificate analysis.

### Step 1: Create Censys Account

1. Buka https://censys.io/
2. Click **"Sign Up"**
3. Choose registration method:
   - Email/Password
   - GitHub account
   - Google account
4. Verify email (jika email method)
5. Login

### Step 2: Get API Credentials

1. Login ke Censys
2. Click **Account** (top right)
3. Click **"API"** atau **"API Keys"**
4. Salin:
   - **UID** (User ID)
   - **Secret** (API Secret)

### Step 3: Set Environment Variables

#### Option 1: PowerShell Session (Temporary)
```powershell
$env:CENSYS_USER_ID = "your-uid-here"
$env:CENSYS_API_SECRET = "your-secret-here"

# Verify
echo $env:CENSYS_USER_ID
echo $env:CENSYS_API_SECRET
```

#### Option 2: Permanent (Windows)
```powershell
[Environment]::SetEnvironmentVariable("CENSYS_USER_ID", "your-uid", "User")
[Environment]::SetEnvironmentVariable("CENSYS_API_SECRET", "your-secret", "User")

# Restart PowerShell
```

#### Option 3: Via Profile
```powershell
# Edit PowerShell profile
notepad $PROFILE

# Add lines:
$env:CENSYS_USER_ID = "your-uid-here"
$env:CENSYS_API_SECRET = "your-secret-here"

# Save and reload
```

### Step 4: Test

```powershell
cd c:\Users\user\Desktop\mzv
.\recon.bat censys "example.com"
```

Expected output:
```
Searching Censys for: example.com
Found 42 certificates
SHA-256: a1b2c3d4...
  Names: *.example.com, example.com
...
```

### Censys Pricing

| Plan | Price | Requests/Day | Features |
|------|-------|--------------|----------|
| Free | $0 | 120 | Certificates, IPv4, Domains |
| Academic | $0 | Unlimited | Untuk .edu emails |
| Premium | $4,950/year | 10,000+ | Enterprise features |

### Tips
- Free tier sufficient untuk most OSINT tasks
- Academic tier jika Anda di university
- Rate limits: 120 queries per day on free tier
- Searches kombinasi bisa powerful (e.g., "*.company.com")

### Example Queries
```
example.com
*.example.com
google.com
"*.github.io"
```

---

## 3. Have I Been Pwned API

### Deskripsi
HIBP adalah free service yang maintains database dari public breaches. **TIDAK MEMERLUKAN API KEY** untuk basic usage.

### Free API Features
- Check email addresses
- Check passwords
- Check breaches
- No authentication required
- Rate limited tapi generous

### Step 1: Basic Usage (No Setup)

```powershell
cd c:\Users\user\Desktop\mzv
.\recon.bat breach user@example.com
.\recon.bat breach admin@company.com
```

### HIBP Pricing

| Plan | Price | Use Case |
|------|-------|----------|
| Free API | $0 | Personal projects, security audits |
| Notify Service | $0 | Email notifications for new breaches |
| Premium API | $3.50/month | Commercial use, priority support |

### HIBP Rules & Limits

- **Rate Limit**: 1 request per 1.5 seconds per IP
- **Use Cases**: Personal security research, user notifications
- **Commercial**: Need proper subscription + attribution
- **Attribution**: Selalu mention "Powered by Have I Been Pwned"

### Tips
- Check HIBP regularly untuk employee emails
- Monitor dengan email notification service
- Use untuk incident response
- Documented dalam compliance checks

### Important Notes
- Data HIBP adalah public database
- If email found = sudah di-breach sebelumnya
- Tidak guarantee data masih di-breach sekarang
- Always recommend password change dan MFA

---

## 🔐 Security Best Practices for API Keys

### 1. Protect Your Keys
```
❌ DON'T:
- Hardcode keys dalam scripts
- Commit keys ke git repository
- Share keys di email atau chat
- Use same key untuk multiple accounts

✅ DO:
- Use environment variables
- Store keys dalam secure vault
- Rotate keys regularly
- Use different keys per environment
```

### 2. .gitignore Configuration
```bash
# Create .gitignore (if not exists)
cat > .gitignore << EOF
# Environment files
.env
.env.local
.env.*.local

# API keys
*_key
*_secret
*.key
*.pem

# Credentials
credentials.json
secrets.json
EOF

git add .gitignore
git commit -m "Add .gitignore for secrets"
```

### 3. Secure Storage Options

#### Option 1: PowerShell Credential Manager
```powershell
# Store credential
$credential = Get-Credential
$credential | Export-CliXml -Path "$env:APPDATA\PowerShell\api_key.xml"

# Retrieve credential
$credential = Import-CliXml -Path "$env:APPDATA\PowerShell\api_key.xml"
$env:SHODAN_API_KEY = $credential.GetNetworkCredential().Password
```

#### Option 2: Windows Vault
```powershell
# Store
cmdkey /add:shodan /user:api /pass:"your-api-key"

# Retrieve
$password = (cmdkey /list:shodan | findstr "Target" | findstr "shodan").Split(" ")[4]
```

#### Option 3: .env File (Local Only)
```bash
# Create .env file (KEEP LOCAL - DON'T COMMIT)
echo "SHODAN_API_KEY=your-key-here" > .env.local

# Load (manual in PowerShell)
$env:SHODAN_API_KEY = "your-key"
```

### 4. Audit & Monitoring
```powershell
# Check what keys are set
Get-ChildItem env: | findstr "SHODAN\|CENSYS"

# Never log keys
Get-ChildItem env: | Where-Object { $_.Name -match "KEY|SECRET" } | Select-Object Name
```

---

## 🧪 Testing Setup

### Test All APIs

Create test script `test-apis.ps1`:
```powershell
# Test Shodan
if ([string]::IsNullOrEmpty($env:SHODAN_API_KEY)) {
    Write-Host "SHODAN API Key: NOT SET" -ForegroundColor Red
} else {
    Write-Host "SHODAN API Key: SET" -ForegroundColor Green
}

# Test Censys
if ([string]::IsNullOrEmpty($env:CENSYS_USER_ID) -or [string]::IsNullOrEmpty($env:CENSYS_API_SECRET)) {
    Write-Host "CENSYS Credentials: NOT SET" -ForegroundColor Red
} else {
    Write-Host "CENSYS Credentials: SET" -ForegroundColor Green
}

# Test HIBP (No setup needed)
Write-Host "HIBP: Ready (No API Key Required)" -ForegroundColor Green

# Try actual queries
Write-Host ""
Write-Host "Testing tools..."
.\cli.ps1 breach user@example.com
```

Run test:
```powershell
cd c:\Users\user\Desktop\mzv\tools
.\test-apis.ps1
```

---

## 🆘 Troubleshooting

### Error: "API key not provided"
```
Solution:
1. Check environment variable is set: echo $env:SHODAN_API_KEY
2. PowerShell might need restart after setting
3. Use correct variable name (case sensitive in some contexts)
4. Verify key is correct at provider website
```

### Error: "Unauthorized" or "401"
```
Solution:
1. API key might be invalid or expired
2. Regenerate new key at provider website
3. Check key isn't in wrong format (extra spaces, etc.)
4. Some APIs require specific permission settings
```

### Error: "Rate limit exceeded"
```
Solution:
1. Wait longer between requests
2. Upgrade to paid plan untuk higher limits
3. Implement request queue/delays dalam script
4. Check if multiple scripts accessing same API
```

### Error: "Connection timeout"
```
Solution:
1. Check internet connection
2. Try different network (corporate firewall blocking?)
3. Use VPN/proxy if ISP blocking
4. Check API service status at provider website
```

---

## 📊 Quick Reference

### Environment Variables Summary
```powershell
# Shodan
$env:SHODAN_API_KEY = "your-key"

# Censys
$env:CENSYS_USER_ID = "your-uid"
$env:CENSYS_API_SECRET = "your-secret"

# HIBP (tidak perlu setup)
```

### Setup Checklist
```
[✓] Shodan account created
[✓] Shodan API key obtained
[✓] Shodan env variable set
[✓] Shodan test successful

[✓] Censys account created
[✓] Censys credentials obtained
[✓] Censys env variables set
[✓] Censys test successful

[✓] HIBP ready (no setup needed)
```

---

## 🔗 Useful Links

- **Shodan**: https://www.shodan.io/
- **Censys**: https://censys.io/
- **HIBP**: https://haveibeenpwned.com/
- **PowerShell Env Vars**: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables

---

**Last Updated**: 2026-08-16
**Tested On**: Windows 10/11 PowerShell 5.1+
