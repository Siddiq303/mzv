# Security Recon CLI

CLI berbasis PowerShell untuk analisis keamanan jaringan yang bersifat defensif dan etis. Project ini dirancang untuk menampilkan informasi umum seperti:

- 🌐 IP publik
- 📍 Resolusi host ke IP
- 🔌 Port yang terbuka (scan)
- 📋 Header HTTP dan fitur keamanan
- 🔐 Informasi SSL/TLS certificate
- 🔍 DNS lookup

## Keunggulan

- ✅ **Tidak perlu install apapun** - Menggunakan PowerShell bawaan Windows
- ✅ **Mudah digunakan** - Command-line yang intuitif
- ✅ **Fleksibel** - Banyak tools dalam satu aplikasi
- ✅ **Aman** - Hanya untuk keamanan defensif

## Instalasi

Tidak perlu instalasi! Cukup clone atau download folder ini.

## Cara Menggunakan

### Cara 1: Menggunakan Batch Script (Paling Mudah)

```bash
recon.bat help
recon.bat public-ip
recon.bat resolve google.com
recon.bat port-scan 8.8.8.8
recon.bat http-headers https://google.com
recon.bat security-check https://google.com
recon.bat dns-lookup google.com
recon.bat ssl-check google.com
```

### Cara 2: Menggunakan PowerShell Script

```bash
powershell -ExecutionPolicy Bypass -File cli.ps1 public-ip
powershell -ExecutionPolicy Bypass -File cli.ps1 resolve google.com
```

## Tools yang Tersedia

| Command | Keterangan | Contoh |
|---------|-----------|--------|
| `help` | Tampilkan bantuan | `recon.bat help` |
| `public-ip` | Tampilkan public IP | `recon.bat public-ip` |
| `resolve <host>` | Resolve hostname ke IP | `recon.bat resolve google.com` |
| `port-scan <host>` | Scan port umum | `recon.bat port-scan 8.8.8.8` |
| `http-headers <url>` | Ambil HTTP headers | `recon.bat http-headers google.com` |
| `security-check <url>` | Periksa security headers | `recon.bat security-check google.com` |
| `dns-lookup <domain>` | DNS lookup | `recon.bat dns-lookup google.com` |
| `ssl-check <host>` | Periksa SSL/TLS cert | `recon.bat ssl-check google.com` |

## Fitur Keamanan yang Dicek

Ketika menggunakan `security-check`, tools ini akan memeriksa:

- **HSTS** (HTTP Strict Transport Security) - Memaksa HTTPS
- **X-Frame-Options** - Proteksi clickjacking
- **X-Content-Type-Options** - Proteksi MIME sniffing
- **Content-Security-Policy** - CSP untuk XSS protection
- **X-XSS-Protection** - Legacy XSS protection

## Catatan Etis ⚠️

**PENTING:** Gunakan tools ini hanya untuk:
- ✅ Lingkungan yang Anda miliki izin/otorisasi
- ✅ Audit keamanan internal
- ✅ Penetration testing yang diizinkan
- ✅ Pemantauan infrastruktur milik Anda

**JANGAN digunakan untuk:**
- ❌ Hacking atau akses tidak sah
- ❌ Aktivitas yang melanggar hukum
- ❌ Sistem yang bukan milik Anda tanpa izin
- ❌ Denial of Service atau aktivitas merusak

Developer bertanggung jawab penuh atas penggunaan tools ini sesuai hukum yang berlaku di yurisdiksi masing-masing.
