#!/bin/bash

# Stop Docker containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Stop Docker Containers"
echo "========================================"
echo ""

cd "$PROJECT_ROOT"

if [ -f "docker/dev/docker-compose.yml" ]; then
    docker-compose -f docker/dev/docker-compose.yml down
    echo "Docker containers stopped."
else
    echo "Docker compose file not found. Skipping docker stop."
fi

echo ""
echo "========================================"
echo "Done!"
echo "========================================"
