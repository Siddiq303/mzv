# 📁 PROJECT STRUCTURE

## Folder Organization

```
mzv/
├── recon.bat                    ⭐ Main launcher (Batch)
├── recon.ps1                    ⭐ Main launcher (PowerShell)
│
├── docs/                        📚 DOCUMENTATION
│   ├── README.md                - Project overview
│   ├── QUICK_START.md           - Quick examples (RECOMMENDED)
│   ├── TOOLS_GUIDE.md           - Detailed guide
│   ├── RINGKASAN_TOOLS.md       - Summary
│   ├── ALL_TOOLS_EXAMPLES.md    - Real output examples
│   └── INDEX.md                 - File structure & guide
│
├── tools/                       🛠️  CLI SCRIPTS
│   ├── recon.bat                - Batch launcher
│   ├── cli.ps1                  - Main PowerShell script
│   └── main.py                  - Python version (optional)
│
├── src/                         📦 SOURCE CODE
│   └── main.js                  - Node.js version (optional)
│
├── package.json                 - Node.js config
├── requirements.txt             - Python dependencies
└── .gitignore                   - Git ignore file
```

---

## 🚀 HOW TO USE

### Method 1: Batch (Easiest - Windows CMD)
```bash
recon.bat help
recon.bat public-ip
recon.bat resolve google.com
recon.bat port-scan google.com 80,443
```

### Method 2: PowerShell
```bash
.\recon.ps1 help
.\recon.ps1 public-ip
.\recon.ps1 resolve google.com
.\recon.ps1 port-scan google.com 80,443
```

### Method 3: Direct PowerShell Script (from tools folder)
```bash
cd tools
.\recon.bat public-ip
```

---

## 📚 DOCUMENTATION

All documentation files are organized in the `docs/` folder:

| File | Content |
|------|---------|
| **README.md** | Project overview & installation |
| **QUICK_START.md** | Quick examples untuk setiap tool ⭐ **START HERE** |
| **TOOLS_GUIDE.md** | Detailed explanation of each tool |
| **RINGKASAN_TOOLS.md** | Indonesian summary of all tools |
| **ALL_TOOLS_EXAMPLES.md** | Real output examples |
| **INDEX.md** | This file (folder structure) |

---

## 🎯 QUICK COMMANDS

```bash
# Show help
recon.bat

# Get your public IP
recon.bat public-ip

# Resolve domain to IP
recon.bat resolve google.com

# Scan ports
recon.bat port-scan google.com 80,443,22,3306

# Get HTTP headers
recon.bat http-headers google.com

# Check security headers
recon.bat security-check google.com

# DNS lookup
recon.bat dns-lookup google.com

# Check SSL certificate
recon.bat ssl-check google.com
```

---

## 📖 RECOMMENDED READING ORDER

1. Start here: `docs/QUICK_START.md`
2. For details: `docs/TOOLS_GUIDE.md`
3. For examples: `docs/ALL_TOOLS_EXAMPLES.md`
4. Indonesian: `docs/RINGKASAN_TOOLS.md`

---

## ✅ 7 TOOLS AVAILABLE

1. **public-ip** - Get your public IP
2. **resolve** - Hostname to IP resolution
3. **port-scan** - Scan ports on host
4. **http-headers** - Get HTTP response headers
5. **security-check** - Check security headers
6. **dns-lookup** - DNS A record lookup
7. **ssl-check** - Check SSL certificate

---

**Location:** `c:\Users\user\Desktop\mzv`

All tools are working and ready to use! 🎉
