# Stop and Clear - Stops Docker containers and optionally clears backend/frontend
# Usage: .\stop-and-clear.ps1 [-Clear]

param(
    [switch]$Clear
)

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Stop and Clear" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Stop Docker containers
Write-Host "Stopping Docker containers..." -ForegroundColor Green
Set-Location $PROJECT_ROOT

$composeFile = Join-Path $PROJECT_ROOT "docker/dev/docker-compose.yml"
if (Test-Path $composeFile) {
    docker-compose -f $composeFile down
    Write-Host "Docker containers stopped." -ForegroundColor Green
} else {
    Write-Host "Docker compose file not found. Skipping docker stop." -ForegroundColor Yellow
}

# Clear backend and frontend if -Clear flag is provided
if ($Clear) {
    Write-Host ""
    Write-Host "Clearing backend and frontend directories..." -ForegroundColor Yellow
    
    $backendDir = Join-Path $PROJECT_ROOT "backend"
    $frontendDir = Join-Path $PROJECT_ROOT "frontend"
    
    # Clear backend
    if (Test-Path $backendDir) {
        Write-Host "Clearing backend directory..." -ForegroundColor Green
        Get-ChildItem -Path $backendDir -Force | Remove-Item -Recurse -Force
        Write-Host "Backend directory cleared." -ForegroundColor Green
    }
    
    # Clear frontend
    if (Test-Path $frontendDir) {
        Write-Host "Clearing frontend directory..." -ForegroundColor Green
        Get-ChildItem -Path $frontendDir -Force | Remove-Item -Recurse -Force
        Write-Host "Frontend directory cleared." -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Directories cleared. Run .\scripts\start-dev.ps1 to re-initialize." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "To also clear backend and frontend directories, run with -Clear flag:" -ForegroundColor Yellow
    Write-Host "  .\stop-and-clear.ps1 -Clear"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
