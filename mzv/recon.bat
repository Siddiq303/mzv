@echo off
REM Security Recon CLI - Main Launcher
REM This script calls the CLI from the tools folder
REM Usage: recon.bat <command> <target> [options]

cd /d %~dp0tools
call recon.bat %*
