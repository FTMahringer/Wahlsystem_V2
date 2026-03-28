# Start development environment
# Auto-initializes backend and frontend if needed

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wahlsystem Development Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path "docker/dev/.env")) {
    Write-Host "Error: docker/dev/.env not found!" -ForegroundColor Red
    Write-Host "Please copy .env.example to docker/dev/.env and configure it." -ForegroundColor Yellow
    exit 1
}

# Initialize backend if needed
if (-not (Test-Path "$PROJECT_ROOT/backend/pom.xml")) {
    Write-Host "Backend not initialized. Running initializer..." -ForegroundColor Yellow
    Write-Host ""
    & "$SCRIPT_DIR/init-backend.ps1"
    Write-Host ""
}

# Initialize frontend if needed
if (-not (Test-Path "$PROJECT_ROOT/frontend/package.json")) {
    Write-Host "Frontend not initialized. Running initializer..." -ForegroundColor Yellow
    Write-Host ""
    & "$SCRIPT_DIR/init-frontend.ps1"
    Write-Host ""
}

Write-Host "Starting Docker containers..." -ForegroundColor Green
Write-Host ""

# Change to dev directory
Set-Location "../docker/dev"

# Build and start services
docker-compose up --build -d

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Development environment started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services available at:"
Write-Host "  - Application:     http://localhost"
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
Write-Host "To stop:      docker-compose -f docker/dev/docker-compose.yml down"
Write-Host ""

Set-Location "../../"
