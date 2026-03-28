# Wipe Frontend - Clears all contents from the frontend folder but keeps the directory
# Usage: .\wipe-frontend.ps1

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR
$FRONTEND_DIR = Join-Path $PROJECT_ROOT "frontend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wiping Frontend Contents" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path $FRONTEND_DIR) {
    Write-Host "Clearing frontend directory: $FRONTEND_DIR" -ForegroundColor Yellow
    # Remove all contents but keep the directory itself
    Get-ChildItem -Path $FRONTEND_DIR -Force | Remove-Item -Recurse -Force
    Write-Host "Frontend directory cleared successfully." -ForegroundColor Green
} else {
    Write-Host "Frontend directory does not exist. Creating empty directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $FRONTEND_DIR | Out-Null
    Write-Host "Empty frontend directory created." -ForegroundColor Green
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
