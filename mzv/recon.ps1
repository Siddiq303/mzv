#!/usr/bin/env pwsh
# Security Recon CLI - Main PowerShell Launcher
# Usage: ./recon.ps1 <command> <target> [options]

$toolsPath = Join-Path $PSScriptRoot "tools"
$cliScript = Join-Path $toolsPath "cli.ps1"

# Call the CLI script from tools folder
& $cliScript @args
