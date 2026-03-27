#!/bin/bash

# Start production environment

set -e

echo "Starting production environment..."

# Check if .env exists
if [ ! -f "docker/prod/.env" ]; then
    echo "Error: docker/prod/.env not found!"
    echo "Please copy .env.example to docker/prod/.env and configure it."
    echo "WARNING: Make sure to change all default passwords!"
    exit 1
fi

# Build frontend first (if needed)
# Uncomment if you want to build frontend before starting
# echo "Building frontend..."
# cd frontend
# npm ci
# npm run build
# cd ..

# Change to prod directory
cd docker/prod

# Pull latest images and start services
docker-compose pull
docker-compose up --build -d

echo ""
echo "Production environment started!"
echo ""
echo "Services available at:"
echo "  - Application: http://localhost"
echo ""
echo "Backend Stack:"
echo "  - Java 26         (Latest)"
echo "  - Spring Boot 4.0.5"
echo "  - Spring Framework 7.x"
echo "  - OpenTelemetry   (Observability)"
echo "  - MariaDB 11.4    (Default)"
echo "  - Redis 7"
echo ""
echo "To view logs: docker-compose -f docker/prod/docker-compose.yml logs -f"
echo "To stop:      docker-compose -f docker/prod/docker-compose.yml down"
