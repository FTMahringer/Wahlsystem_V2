# Start development environment

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR
$DEV_ENV_FILE = "$PROJECT_ROOT/docker/dev/.env"

function Get-EnvValue {
    param(
        [string]$Path,
        [string]$Key
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    $line = Get-Content $Path | Where-Object { $_ -match "^\s*$Key=" } | Select-Object -First 1
    if (-not $line) {
        return $null
    }

    return ($line -split "=", 2)[1].Trim()
}

function Test-DockerBindFile {
    param(
        [string]$HostPath,
        [string]$RelativeFile
    )

    $dockerPath = ($HostPath -replace '\\', '/')
    $checkCommand = "[ -f '/mnt/src/$RelativeFile' ]"
    docker run --rm -v "${dockerPath}:/mnt/src" alpine:3.20 sh -lc $checkCommand | Out-Null
    return $LASTEXITCODE -eq 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wahlsystem Development Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path $DEV_ENV_FILE)) {
    Write-Host "Error: docker/dev/.env not found!" -ForegroundColor Red
    Write-Host "Please copy .env.example to docker/dev/.env and configure it." -ForegroundColor Yellow
    exit 1
}

# Check if backend exists
if (-not (Test-Path "$PROJECT_ROOT/backend/pom.xml")) {
    Write-Host "Error: Backend not found at $PROJECT_ROOT\backend" -ForegroundColor Red
    Write-Host "Please ensure the backend is initialized." -ForegroundColor Yellow
    exit 1
}

# Check if frontend exists
if (-not (Test-Path "$PROJECT_ROOT/frontend/package.json")) {
    Write-Host "Error: Frontend not found at $PROJECT_ROOT\frontend" -ForegroundColor Red
    Write-Host "Please ensure the frontend is initialized." -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting Docker containers..." -ForegroundColor Green
Write-Host ""

$frontendSource = "../../frontend"
$backendSource = "../../backend"
$fallbackMode = $false
$projectName = Get-EnvValue -Path $DEV_ENV_FILE -Key "PROJECT_NAME"
if (-not $projectName) {
    $projectName = "Wahlsystem"
}

$frontendBindOk = Test-DockerBindFile -HostPath "$PROJECT_ROOT/frontend" -RelativeFile "package.json"
$backendBindOk = Test-DockerBindFile -HostPath "$PROJECT_ROOT/backend" -RelativeFile ".mvn/wrapper/maven-wrapper.jar"

if (-not $frontendBindOk -or -not $backendBindOk) {
    $fallbackMode = $true
    $frontendSource = "frontend_app"
    $backendSource = "backend_app"

    Write-Host "Warning: Docker cannot read the project files through bind mounts on this drive." -ForegroundColor Yellow
    Write-Host "Falling back to image-backed app volumes so the dev stack can still start." -ForegroundColor Yellow
    Write-Host "Live reload is disabled in this fallback mode; rerun this script after code changes." -ForegroundColor Yellow
    Write-Host ""

    docker volume rm "$projectName-frontend-app-dev" "$projectName-backend-app-dev" 2>$null | Out-Null
}

# Change to dev directory
Set-Location "$PROJECT_ROOT/docker/dev"

# Build and start services
$env:FRONTEND_APP_SOURCE = $frontendSource
$env:BACKEND_APP_SOURCE = $backendSource
docker-compose up --build -d
$env:FRONTEND_APP_SOURCE = $null
$env:BACKEND_APP_SOURCE = $null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Development environment started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
if ($fallbackMode) {
    Write-Host "Startup mode: fallback (image-backed app volumes, no live reload)" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "Services available at:"
Write-Host "  - Frontend (HMR):  http://localhost:5173"
Write-Host "  - Backend API:     http://localhost:8080"
Write-Host "  - Java Debug Port: localhost:5005"
Write-Host "  - phpMyAdmin:      http://localhost:8081"
Write-Host "  - Redis Commander: http://localhost:8082"
Write-Host ""
Write-Host "Stack:"
Write-Host "  - Java 26"
Write-Host "  - Spring Boot 4.0.5"
Write-Host "  - Vue 3.5.31+"
Write-Host "  - MariaDB 11.4"
Write-Host "  - Redis 7"
Write-Host ""
Write-Host "Project initialized at:"
Write-Host "  - Backend:  $PROJECT_ROOT\backend"
Write-Host "  - Frontend: $PROJECT_ROOT\frontend"
Write-Host ""
Write-Host "To view logs: docker-compose -f docker/dev/docker-compose.yml logs -f"
Write-Host "To stop:      .\scripts\stop-and-clear.ps1"
Write-Host ""

Set-Location "$PROJECT_ROOT"
