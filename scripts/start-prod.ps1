# Start production environment

$ErrorActionPreference = "Stop"

Write-Host "Starting production environment..." -ForegroundColor Green

# Check if .env exists
if (-not (Test-Path "docker/prod/.env")) {
    Write-Host "Error: docker/prod/.env not found!" -ForegroundColor Red
    Write-Host "Please copy .env.example to docker/prod/.env and configure it." -ForegroundColor Yellow
    Write-Host "WARNING: Make sure to change all default passwords!" -ForegroundColor Red
    exit 1
}

# Build frontend first (if needed)
# Uncomment if you want to build frontend before starting
# Write-Host "Building frontend..." -ForegroundColor Green
# Set-Location frontend
# npm ci
# npm run build
# Set-Location ..

# Change to prod directory
Set-Location docker/prod

# Pull latest images and start services
docker-compose pull
docker-compose up --build -d

Write-Host ""
Write-Host "Production environment started!" -ForegroundColor Green
Write-Host ""
Write-Host "Services available at:"
Write-Host "  - Application: http://localhost"
Write-Host ""
Write-Host "Backend Stack:"
Write-Host "  - Java 26         (Latest)"
Write-Host "  - Spring Boot 4.0.5"
Write-Host "  - Spring Framework 7.x"
Write-Host "  - OpenTelemetry   (Observability)"
Write-Host "  - MariaDB 11.4    (Default)"
Write-Host "  - Redis 7"
Write-Host ""
Write-Host "To view logs: docker-compose -f docker/prod/docker-compose.yml logs -f"
Write-Host "To stop:      docker-compose -f docker/prod/docker-compose.yml down"
