# 🛡️ Security Reconnaissance CLI

A comprehensive CLI tool for security reconnaissance and network analysis. Built with PowerShell (Windows native - no installation required).

---

## 📋 QUICK START

### Run commands from root folder:
```bash
recon.bat help
recon.bat public-ip
recon.bat resolve google.com
recon.bat port-scan google.com 80,443
```

**OR** using PowerShell:
```bash
.\recon.ps1 public-ip
.\recon.ps1 resolve google.com
```

---

## 🎯 15 Tools Included

### RECONNAISSANCE TOOLS (7)
| # | Tool | Command | Purpose |
|---|------|---------|---------|
| 1 | public-ip | `recon.bat public-ip` | Get your public IP |
| 2 | resolve | `recon.bat resolve (host)` | Resolve domain to IP |
| 3 | port-scan | `recon.bat port-scan (host)` | Scan open ports |
| 4 | http-headers | `recon.bat http-headers (url)` | Get HTTP headers |
| 5 | security-check | `recon.bat security-check (url)` | Check security headers |
| 6 | dns-lookup | `recon.bat dns-lookup (domain)` | DNS lookup (A records) |
| 7 | ssl-check | `recon.bat ssl-check (host)` | Check SSL certificate |

### OSINT TOOLS (8)
| # | Tool | Command | Purpose |
|---|------|---------|---------|
| 8 | breach | `recon.bat breach (email)` | Check Have I Been Pwned |
| 9 | whois | `recon.bat whois (domain)` | WHOIS domain information |
| 10 | google-dorks | `recon.bat google-dorks (domain)` | Generate Google dorks |
| 11 | shodan | `recon.bat shodan (query)` | Search Shodan API |
| 12 | censys | `recon.bat censys (query)` | Search Censys certificates |
| 13 | email-enum | `recon.bat email-enum (domain)` | Enumerate email patterns |
| 14 | username-check | `recon.bat username-check (name)` | Check username on platforms |
| 15 | dns-enum | `recon.bat dns-enum (domain)` | Extended DNS enumeration |

---

## 📁 Project Structure

```
mzv/
├── recon.bat                ⭐ Main launcher
├── recon.ps1                ⭐ PowerShell launcher
│
├── docs/                    📚 Documentation
│   ├── INDEX.md             - Folder structure
│   ├── QUICK_START.md       - Quick examples (START HERE!)
│   ├── TOOLS_GUIDE.md       - Detailed guide
│   ├── RINGKASAN_TOOLS.md   - Indonesian summary
│   └── ALL_TOOLS_EXAMPLES.md - Real output examples
│
├── tools/                   🛠️ CLI Scripts
│   ├── recon.bat            - Batch launcher
│   ├── cli.ps1              - Main PowerShell script
│   └── main.py              - Python version
│
└── src/                     📦 Source code
    └── main.js              - Node.js version
```

---

## 📖 DOCUMENTATION

All documentation is in the `docs/` folder:

- **START HERE:** `docs/QUICK_START.md` - Quick examples for each tool
- **OSINT Tools:** `docs/OSINT_TOOLS.md` - Comprehensive OSINT documentation (NEW!)
- **API Setup:** `docs/OSINT_API_SETUP.md` - API configuration guide (NEW!)
- **Detailed Guide:** `docs/TOOLS_GUIDE.md` - In-depth explanation
- **Real Examples:** `docs/ALL_TOOLS_EXAMPLES.md` - Output examples
- **Indonesian:** `docs/RINGKASAN_TOOLS.md` - Ringkasan lengkap
- **Structure:** `docs/INDEX.md` - Project structure

---

## ✨ Features

✅ **No Installation Required** - Uses PowerShell (Windows built-in)
✅ **15 Different Tools** - Reconnaissance + OSINT capabilities  
✅ **Batch & PowerShell** - Choose your preferred interface
✅ **Fully Tested** - All tools verified and working
✅ **Comprehensive Docs** - Detailed documentation and examples
✅ **API Integration** - Shodan, Censys, Have I Been Pwned
✅ **Easy to Use** - Simple command-line interface

---

## 🚀 EXAMPLES

### Check Your Public IP
```bash
recon.bat public-ip
```

### Resolve Domain
```bash
recon.bat resolve google.com
# Output: 216.239.38.120
```

### Scan Ports
```bash
recon.bat port-scan google.com 80,443,22
# Output: 80 OPEN [HTTP], 443 OPEN [HTTPS], 22 closed [SSH]
```

### Check Security Headers
```bash
recon.bat security-check google.com
# Output: YES X-Frame-Options, NO Strict-Transport-Security, etc.
```

### Check SSL Certificate
```bash
recon.bat ssl-check google.com
# Output: Certificate details with validity dates
```

---

## ⚖️ ETHICAL USAGE

✅ **Authorized Use:**
- Audit websites you own
- Internal network assessment
- Educational purposes
- Authorized penetration testing

❌ **Prohibited Use:**
- Unauthorized scanning
- Hacking attempts
- Denial of Service
- Illegal activities

---

## 📞 SUPPORT

For detailed information:
1. Read `docs/QUICK_START.md` for quick examples
2. Check `docs/TOOLS_GUIDE.md` for detailed explanation
3. See `docs/ALL_TOOLS_EXAMPLES.md` for output examples

---

## 📍 Location

`c:\Users\user\Desktop\mzv`

---

**Status:** ✅ All tools ready to use!
