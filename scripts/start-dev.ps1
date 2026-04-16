# Start development environment

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wahlsystem Development Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path "$PROJECT_ROOT/docker/dev/.env")) {
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

# Change to dev directory
Set-Location "$PROJECT_ROOT/docker/dev"

# Build and start services
docker-compose up --build -d

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Development environment started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
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
