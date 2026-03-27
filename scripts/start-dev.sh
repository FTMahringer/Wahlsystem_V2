#!/bin/bash

# Start development environment
# Auto-initializes backend and frontend if needed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Wahlsystem Development Environment"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f "docker/dev/.env" ]; then
    echo "Error: docker/dev/.env not found!"
    echo "Please copy .env.example to docker/dev/.env and configure it."
    exit 1
fi

# Initialize backend if needed
if [ ! -f "$PROJECT_ROOT/backend/pom.xml" ]; then
    echo "Backend not initialized. Running initializer..."
    echo ""
    bash "$SCRIPT_DIR/init-backend.sh"
    echo ""
fi

# Initialize frontend if needed
if [ ! -f "$PROJECT_ROOT/frontend/package.json" ]; then
    echo "Frontend not initialized. Running initializer..."
    echo ""
    bash "$SCRIPT_DIR/init-frontend.sh"
    echo ""
fi

echo "Starting Docker containers..."
echo ""

# Change to dev directory
cd docker/dev

# Build and start services
docker-compose up --build -d

echo ""
echo "========================================"
echo "Development environment started!"
echo "========================================"
echo ""
echo "Services available at:"
echo "  - Application:     http://localhost"
echo "  - Frontend (HMR):  http://localhost:5173"
echo "  - Backend API:     http://localhost:8080"
echo "  - Java Debug Port: localhost:5005"
echo "  - phpMyAdmin:      http://localhost:8081"
echo "  - Redis Commander: http://localhost:8082"
echo ""
echo "Stack:"
echo "  - Java 26"
echo "  - Spring Boot 4.0.5"
echo "  - Vue 3.5.31+"
echo "  - MariaDB 11.4"
echo "  - Redis 7"
echo ""
echo "Project initialized at:"
echo "  - Backend:  $PROJECT_ROOT/backend"
echo "  - Frontend: $PROJECT_ROOT/frontend"
echo ""
echo "To view logs: docker-compose -f docker/dev/docker-compose.yml logs -f"
echo "To stop:      docker-compose -f docker/dev/docker-compose.yml down"
echo ""
