# Stop Docker containers

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Stop Docker Containers" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $PROJECT_ROOT

$composeFile = Join-Path $PROJECT_ROOT "docker/dev/docker-compose.yml"
if (Test-Path $composeFile) {
    docker-compose -f $composeFile down
    Write-Host "Docker containers stopped." -ForegroundColor Green
} else {
    Write-Host "Docker compose file not found. Skipping docker stop." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
