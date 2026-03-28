# Wipe Backend - Clears all contents from the backend folder but keeps the directory
# Usage: .\wipe-backend.ps1

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR
$BACKEND_DIR = Join-Path $PROJECT_ROOT "backend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wiping Backend Contents" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path $BACKEND_DIR) {
    Write-Host "Clearing backend directory: $BACKEND_DIR" -ForegroundColor Yellow
    # Remove all contents but keep the directory itself
    Get-ChildItem -Path $BACKEND_DIR -Force | Remove-Item -Recurse -Force
    Write-Host "Backend directory cleared successfully." -ForegroundColor Green
} else {
    Write-Host "Backend directory does not exist. Creating empty directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $BACKEND_DIR | Out-Null
    Write-Host "Empty backend directory created." -ForegroundColor Green
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
