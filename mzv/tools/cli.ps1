#!/usr/bin/env pwsh
param(
    [string]$Command,
    [string]$Target,
    [string]$Options,
    [int]$Port = 443
)

$COMMON_PORTS = @{
    21="FTP"; 22="SSH"; 23="Telnet"; 25="SMTP"; 53="DNS"
    80="HTTP"; 110="POP3"; 143="IMAP"; 443="HTTPS"
    465="SMTPS"; 587="SMTP-Sub"; 993="IMAPS"; 995="POP3S"
    1433="MSSQL"; 1521="Oracle"; 3306="MySQL"; 3389="RDP"
    5432="PostgreSQL"; 8080="HTTP-Alt"; 8443="HTTPS-Alt"
    9200="Elasticsearch"; 27017="MongoDB"
}

function Show-Help {
    Write-Host ""
    Write-Host "=== SECURITY RECON CLI + OSINT TOOLS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "RECONNAISSANCE TOOLS:" -ForegroundColor Yellow
    Write-Host "  public-ip            - Get your public IP address"
    Write-Host "  resolve (host)       - Resolve hostname to IP"
    Write-Host "  port-scan (host)     - Scan common ports"
    Write-Host "  http-headers (url)   - Get HTTP headers"
    Write-Host "  security-check (url) - Check security headers"
    Write-Host "  dns-lookup (domain)  - DNS A/MX/TXT records"
    Write-Host "  ssl-check (host)     - Check SSL certificate"
    Write-Host ""
    Write-Host "OSINT TOOLS:" -ForegroundColor Yellow
    Write-Host "  breach (email)       - Check Have I Been Pwned"
    Write-Host "  whois (domain)       - WHOIS information"
    Write-Host "  google-dorks (domain) - Generate Google dorks"
    Write-Host "  shodan (query)       - Search Shodan API"
    Write-Host "  censys (query)       - Search Censys certificates"
    Write-Host "  email-enum (domain)  - Email pattern enumeration"
    Write-Host "  username-check (name) - Check username on platforms"
    Write-Host "  dns-enum (domain)    - Extended DNS enumeration"
    Write-Host ""
    Write-Host "Usage: ./cli.ps1 (command) (target) (options)" -ForegroundColor Green
    Write-Host ""
}

# ==================== RECONNAISSANCE TOOLS ====================

function Get-PublicIP {
    try {
        Write-Host "Getting public IP..." -ForegroundColor Yellow
        $response = Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -TimeoutSec 10
        Write-Host "Public IP: $($response.ip)" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to get public IP" -ForegroundColor Red
    }
}

function Resolve-HostName {
    param([string]$HostName)
    if ([string]::IsNullOrEmpty($HostName)) {
        Write-Host "ERROR: Host required" -ForegroundColor Red
        return
    }
    try {
        Write-Host "Resolving $HostName..." -ForegroundColor Yellow
        $ips = [System.Net.Dns]::GetHostAddresses($HostName) | Select-Object -ExpandProperty IPAddressToString
        Write-Host "Host: $HostName" -ForegroundColor Green
        foreach ($ip in $ips) {
            Write-Host "  $ip" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "ERROR: Resolution failed" -ForegroundColor Red
    }
}

function Invoke-PortScan {
    param([string]$HostName, [string]$PortList)
    if ([string]::IsNullOrEmpty($HostName)) {
        Write-Host "ERROR: Host required" -ForegroundColor Red
        return
    }
    
    $ports = if ([string]::IsNullOrEmpty($PortList)) {
        $COMMON_PORTS.Keys | Sort-Object
    } else {
        $PortList -split "," | ForEach-Object { [int]$_.Trim() }
    }
    
    Write-Host "Scanning $HostName..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($p in $ports) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $ar = $tcp.BeginConnect($HostName, $p, $null, $null)
        $wait = $ar.AsyncWaitHandle.WaitOne(1000, $false)
        
        if ($wait -and $tcp.Connected) {
            $svc = if ($COMMON_PORTS.ContainsKey($p)) { $COMMON_PORTS[$p] } else { "Unknown" }
            Write-Host "  $p : OPEN   ($svc)" -ForegroundColor Green
        } else {
            $svc = if ($COMMON_PORTS.ContainsKey($p)) { $COMMON_PORTS[$p] } else { "Unknown" }
            Write-Host "  $p : closed ($svc)" -ForegroundColor Gray
        }
        $tcp.Close()
    }
}

function Get-HTTPHeaders {
    param([string]$Url)
    if ([string]::IsNullOrEmpty($Url)) {
        Write-Host "ERROR: URL required" -ForegroundColor Red
        return
    }
    
    $fullUrl = if ($Url -match "^https?://") { $Url } else { "https://$Url" }
    
    try {
        Write-Host "Fetching headers from $fullUrl..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing -TimeoutSec 10
        
        Write-Host ""
        Write-Host "URL: $($response.BaseResponse.ResponseUri)" -ForegroundColor Green
        Write-Host ""
        
        foreach ($h in $response.Headers.Keys) {
            Write-Host "$h : $($response.Headers[$h])" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "ERROR: Failed to get headers" -ForegroundColor Red
    }
}

function Test-SecurityHeaders {
    param([string]$Url)
    if ([string]::IsNullOrEmpty($Url)) {
        Write-Host "ERROR: URL required" -ForegroundColor Red
        return
    }
    
    $fullUrl = if ($Url -match "^https?://") { $Url } else { "https://$Url" }
    
    try {
        Write-Host "Checking security headers..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing -TimeoutSec 10
        
        Write-Host ""
        Write-Host "URL: $($response.BaseResponse.ResponseUri)" -ForegroundColor Green
        Write-Host ""
        
        $checks = @(
            "Strict-Transport-Security",
            "X-Frame-Options",
            "X-Content-Type-Options",
            "Content-Security-Policy",
            "X-XSS-Protection"
        )
        
        foreach ($check in $checks) {
            $val = $response.Headers[$check]
            if ($val) {
                Write-Host "YES $check" -ForegroundColor Green
            } else {
                Write-Host "NO  $check (MISSING)" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "ERROR: Failed to check headers" -ForegroundColor Red
    }
}

function Invoke-DNSLookup {
    param([string]$Domain)
    if ([string]::IsNullOrEmpty($Domain)) {
        Write-Host "ERROR: Domain required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "DNS Lookup for $Domain..." -ForegroundColor Yellow
        Write-Host ""
        
        $aRecords = [System.Net.Dns]::GetHostAddresses($Domain)
        Write-Host "A Records:" -ForegroundColor Green
        foreach ($rec in $aRecords) {
            Write-Host "  $rec" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "ERROR: DNS lookup failed" -ForegroundColor Red
    }
}

function Test-SSLCert {
    param([string]$HostName, [int]$PortNum = 443)
    if ([string]::IsNullOrEmpty($HostName)) {
        Write-Host "ERROR: Host required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Checking SSL certificate..." -ForegroundColor Yellow
        
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect($HostName, $PortNum)
        
        $stream = $tcp.GetStream()
        $ssl = New-Object System.Net.Security.SslStream($stream, $false)
        $ssl.AuthenticateAsClient($HostName)
        
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($ssl.RemoteCertificate)
        
        Write-Host ""
        Write-Host "Host: $HostName`:$PortNum" -ForegroundColor Green
        Write-Host "Subject: $($cert.Subject)" -ForegroundColor Cyan
        Write-Host "Issuer: $($cert.Issuer)" -ForegroundColor Cyan
        Write-Host "Valid From: $($cert.NotBefore)" -ForegroundColor Cyan
        Write-Host "Valid Until: $($cert.NotAfter)" -ForegroundColor Cyan
        
        if ($cert.NotAfter -lt (Get-Date)) {
            Write-Host "WARNING: Certificate EXPIRED!" -ForegroundColor Red
        } elseif ($cert.NotAfter -lt (Get-Date).AddDays(30)) {
            Write-Host "WARNING: Certificate expires in 30 days" -ForegroundColor Yellow
        }
        
        $ssl.Close()
        $tcp.Close()
    } catch {
        Write-Host "ERROR: SSL check failed" -ForegroundColor Red
    }
}

# ==================== OSINT TOOLS ====================

function Test-BreachHIBP {
    param([string]$Email)
    if ([string]::IsNullOrEmpty($Email)) {
        Write-Host "ERROR: Email required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Checking Have I Been Pwned for: $Email..." -ForegroundColor Yellow
        
        $encodedEmail = [System.Uri]::EscapeDataString($Email)
        $uri = "https://haveibeenpwned.com/api/v3/breachedaccount/$encodedEmail"
        
        $headers = @{
            "User-Agent" = "Recon-CLI"
            "Accept" = "application/json"
        }
        
        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -TimeoutSec 10 -ErrorAction Stop
            
            Write-Host ""
            Write-Host "WARNING: EMAIL FOUND IN BREACHES!" -ForegroundColor Red
            Write-Host ""
            
            foreach ($breach in $response) {
                Write-Host "Breach: $($breach.Name)" -ForegroundColor Red
                Write-Host "  Date: $($breach.BreachDate)" -ForegroundColor Yellow
                Write-Host "  Title: $($breach.Title)" -ForegroundColor Cyan
                Write-Host ""
            }
        } catch {
            if ($_.Exception.Response.StatusCode -eq 404) {
                Write-Host ""
                Write-Host "OK: Email NOT found in any known breaches" -ForegroundColor Green
            } else {
                Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "ERROR: Failed to check HIBP" -ForegroundColor Red
    }
}

function Get-WhoisInfo {
    param([string]$Domain)
    if ([string]::IsNullOrEmpty($Domain)) {
        Write-Host "ERROR: Domain required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Fetching WHOIS information for: $Domain..." -ForegroundColor Yellow
        
        $cleanDomain = $Domain -replace "^www\.", ""
        
        if (Get-Command whois -ErrorAction SilentlyContinue) {
            $info = whois $cleanDomain
            Write-Host ""
            Write-Host $info
        } else {
            Write-Host ""
            Write-Host "Domain: $cleanDomain" -ForegroundColor Green
            
            try {
                $dns = [System.Net.Dns]::GetHostAddresses($cleanDomain)
                Write-Host "IP Address: $($dns[0])" -ForegroundColor Cyan
            } catch {
                Write-Host "Could not resolve IP" -ForegroundColor Yellow
            }
            
            Write-Host ""
            Write-Host "Note: Install whois command for full WHOIS details" -ForegroundColor Gray
        }
    } catch {
        Write-Host "ERROR: Failed to get WHOIS info" -ForegroundColor Red
    }
}

function Get-GoogleDorks {
    param([string]$Domain)
    if ([string]::IsNullOrEmpty($Domain)) {
        Write-Host "ERROR: Domain required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Generating Google Dorks for: $Domain" -ForegroundColor Yellow
        Write-Host ""
        
        $dorks = @(
            "site:$Domain",
            "site:$Domain filetype:pdf",
            "site:$Domain filetype:xls",
            "site:$Domain filetype:doc",
            "site:$Domain admin OR login",
            "site:$Domain password OR pass",
            "site:$Domain confidential OR secret",
            "site:$Domain inurl:admin",
            "site:$Domain inurl:login",
            "site:$Domain inurl:api",
            "site:$Domain cache:",
            "site:$Domain SQL error",
            "site:$Domain mysql_fetch",
            "site:$Domain intitle:index.of",
            "site:$Domain ext:config OR ext:xml OR ext:json"
        )
        
        Write-Host "GOOGLE DORKS FOR: $Domain" -ForegroundColor Cyan
        Write-Host "=================================" -ForegroundColor Gray
        Write-Host ""
        
        $i = 1
        foreach ($dork in $dorks) {
            Write-Host "$i. $dork" -ForegroundColor Yellow
            $i++
        }
        
        Write-Host ""
        Write-Host "Use these dorks in Google Search to find:" -ForegroundColor Gray
        Write-Host "  - Exposed files and documents" -ForegroundColor Gray
        Write-Host "  - Admin panels and login pages" -ForegroundColor Gray
        Write-Host "  - Configuration files" -ForegroundColor Gray
    } catch {
        Write-Host "ERROR: Failed to generate dorks" -ForegroundColor Red
    }
}

function Invoke-ShodanSearch {
    param([string]$Query, [string]$ApiKey)
    
    if ([string]::IsNullOrEmpty($Query)) {
        Write-Host "ERROR: Query required" -ForegroundColor Red
        return
    }
    
    $key = if ([string]::IsNullOrEmpty($ApiKey)) { $env:SHODAN_API_KEY } else { $ApiKey }
    
    if ([string]::IsNullOrEmpty($key)) {
        Write-Host "Shodan API key not provided" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Get free Shodan API key at https://www.shodan.io/" -ForegroundColor Cyan
        Write-Host "Set: `$env:SHODAN_API_KEY = 'your-key'" -ForegroundColor Gray
        return
    }
    
    try {
        Write-Host "Searching Shodan for: $Query" -ForegroundColor Yellow
        
        $uri = "https://api.shodan.io/shodan/host/search?key=$key&query=$([System.Uri]::EscapeDataString($Query))"
        
        $response = Invoke-RestMethod -Uri $uri -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.matches.Count -eq 0) {
            Write-Host "No results found" -ForegroundColor Yellow
            return
        }
        
        Write-Host ""
        Write-Host "Found $($response.total) results" -ForegroundColor Green
        Write-Host ""
        
        foreach ($match in $response.matches | Select-Object -First 10) {
            Write-Host "IP: $($match.ip_str)" -ForegroundColor Cyan
            Write-Host "  Port: $($match.port)" -ForegroundColor Green
            Write-Host "  Org: $($match.org)" -ForegroundColor Yellow
            if ($match.http -and $match.http.title) {
                Write-Host "  Title: $($match.http.title)" -ForegroundColor Cyan
            }
            Write-Host ""
        }
    } catch {
        Write-Host "ERROR: Shodan search failed" -ForegroundColor Red
    }
}

function Search-Censys {
    param([string]$Query, [string]$UserId)
    
    if ([string]::IsNullOrEmpty($Query)) {
        Write-Host "ERROR: Query required" -ForegroundColor Red
        return
    }
    
    $userId = if ([string]::IsNullOrEmpty($UserId)) { $env:CENSYS_USER_ID } else { $UserId }
    $apiSecret = $env:CENSYS_API_SECRET
    
    if ([string]::IsNullOrEmpty($userId) -or [string]::IsNullOrEmpty($apiSecret)) {
        Write-Host "Censys credentials not provided" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Get Censys API credentials at https://censys.io/" -ForegroundColor Cyan
        Write-Host 'Set: $env:CENSYS_USER_ID = "your-id"' -ForegroundColor Gray
        Write-Host 'Set: $env:CENSYS_API_SECRET = "your-secret"' -ForegroundColor Gray
        return
    }
    
    try {
        Write-Host "Searching Censys for: $Query" -ForegroundColor Yellow
        
        $auth = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$userId`:$apiSecret"))
        $headers = @{ "Authorization" = "Basic $auth" }
        
        $body = @{ "q" = $Query } | ConvertTo-Json
        $uri = "https://api.censys.io/v1/certificates/search"
        
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -TimeoutSec 10 -ErrorAction Stop
        
        Write-Host ""
        Write-Host "Found $($response.metadata.count) certificates" -ForegroundColor Green
        Write-Host ""
        
        foreach ($cert in $response.results | Select-Object -First 10) {
            Write-Host "SHA-256: $($cert.sha256_fingerprint)" -ForegroundColor Cyan
            Write-Host "  Names: $($cert.names -join ', ')" -ForegroundColor Yellow
            Write-Host ""
        }
    } catch {
        Write-Host "ERROR: Censys search failed" -ForegroundColor Red
    }
}

function Find-Emails {
    param([string]$Domain)
    if ([string]::IsNullOrEmpty($Domain)) {
        Write-Host "ERROR: Domain required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Enumerating email patterns for: $Domain" -ForegroundColor Yellow
        Write-Host ""
        
        $patterns = @(
            "admin", "support", "info", "contact", "sales", "marketing", "hr",
            "accounts", "billing", "noreply", "hello", "help", "abuse", "security"
        )
        
        Write-Host "COMMON EMAIL PATTERNS:" -ForegroundColor Cyan
        Write-Host "=====================" -ForegroundColor Gray
        Write-Host ""
        
        foreach ($pattern in $patterns) {
            Write-Host "$pattern@$Domain" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "ERROR: Email enumeration failed" -ForegroundColor Red
    }
}

function Check-Username {
    param([string]$Username)
    if ([string]::IsNullOrEmpty($Username)) {
        Write-Host "ERROR: Username required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Checking username: $Username" -ForegroundColor Yellow
        Write-Host ""
        
        $sites = @(
            @{ Name = "GitHub"; Url = "https://github.com/$Username" },
            @{ Name = "Twitter"; Url = "https://twitter.com/$Username" },
            @{ Name = "Instagram"; Url = "https://instagram.com/$Username" },
            @{ Name = "LinkedIn"; Url = "https://linkedin.com/in/$Username" },
            @{ Name = "Reddit"; Url = "https://reddit.com/user/$Username" },
            @{ Name = "YouTube"; Url = "https://youtube.com/@$Username" }
        )
        
        Write-Host "CHECKING USERNAME:" -ForegroundColor Cyan
        Write-Host "==================" -ForegroundColor Gray
        Write-Host ""
        
        foreach ($site in $sites) {
            try {
                $response = Invoke-WebRequest -Uri $site.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    Write-Host "OK $($site.Name)" -ForegroundColor Green
                }
            } catch {
                Write-Host "NO $($site.Name)" -ForegroundColor Gray
            }
        }
        
    } catch {
        Write-Host "ERROR: Username check failed" -ForegroundColor Red
    }
}

function Invoke-DNSEnum {
    param([string]$Domain)
    if ([string]::IsNullOrEmpty($Domain)) {
        Write-Host "ERROR: Domain required" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Extended DNS enumeration for: $Domain" -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "A Records:" -ForegroundColor Green
        try {
            $aRecords = [System.Net.Dns]::GetHostAddresses($Domain)
            foreach ($rec in $aRecords) {
                Write-Host "  $rec" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "  Could not resolve" -ForegroundColor Gray
        }
        Write-Host ""
        
        Write-Host "MX Records:" -ForegroundColor Green
        try {
            $mxRecords = nslookup -type=MX $Domain 2>$null | Select-String "mail"
            if ($mxRecords) {
                $mxRecords | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
            } else {
                Write-Host "  No MX records found" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  Could not resolve" -ForegroundColor Gray
        }
        Write-Host ""
        
        Write-Host "NS Records:" -ForegroundColor Green
        try {
            $nsRecords = nslookup -type=NS $Domain 2>$null | Select-String "nameserver"
            if ($nsRecords) {
                $nsRecords | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
            } else {
                Write-Host "  No NS records found" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  Could not resolve" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "ERROR: DNS enumeration failed" -ForegroundColor Red
    }
}

# ==================== MAIN ====================

if ([string]::IsNullOrEmpty($Command) -or $Command -eq "help" -or $Command -eq "-h") {
    Show-Help
    exit
}

switch ($Command.ToLower()) {
    "public-ip" { Get-PublicIP }
    "resolve" { Resolve-HostName -HostName $Target }
    "port-scan" { Invoke-PortScan -HostName $Target -PortList $Options }
    "http-headers" { Get-HTTPHeaders -Url $Target }
    "security-check" { Test-SecurityHeaders -Url $Target }
    "dns-lookup" { Invoke-DNSLookup -Domain $Target }
    "ssl-check" { Test-SSLCert -HostName $Target -PortNum $Port }
    "breach" { Test-BreachHIBP -Email $Target }
    "whois" { Get-WhoisInfo -Domain $Target }
    "google-dorks" { Get-GoogleDorks -Domain $Target }
    "shodan" { Invoke-ShodanSearch -Query $Target -ApiKey $Options }
    "censys" { Search-Censys -Query $Target -UserId $Options }
    "email-enum" { Find-Emails -Domain $Target }
    "username-check" { Check-Username -Username $Target }
    "dns-enum" { Invoke-DNSEnum -Domain $Target }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}
