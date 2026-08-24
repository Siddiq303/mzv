@echo off
REM Security Recon CLI - Batch Launcher
REM Usage: recon.bat <command> <target> [options]

if "%1"=="" (
    powershell -ExecutionPolicy Bypass -File "%~dp0cli.ps1" help
) else (
    powershell -ExecutionPolicy Bypass -File "%~dp0cli.ps1" %*
)
