#!/bin/bash

# Stop and Clear - Stops Docker containers and optionally clears backend/frontend
# Usage: ./stop-and-clear.sh [--clear]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

CLEAR_FLAG=false

# Parse arguments
if [ "$1" == "--clear" ]; then
    CLEAR_FLAG=true
fi

echo "========================================"
echo "Stop and Clear"
echo "========================================"

# Stop Docker containers
echo "Stopping Docker containers..."
cd "$PROJECT_ROOT"

if [ -f "docker/dev/docker-compose.yml" ]; then
    docker-compose -f docker/dev/docker-compose.yml down
    echo "Docker containers stopped."
else
    echo "Docker compose file not found. Skipping docker stop."
fi

# Clear backend and frontend if --clear flag is provided
if [ "$CLEAR_FLAG" = true ]; then
    echo ""
    echo "Clearing backend and frontend directories..."
    
    # Clear backend
    if [ -d "$PROJECT_ROOT/backend" ]; then
        echo "Clearing backend directory..."
        rm -rf "$PROJECT_ROOT/backend"/*
        rm -rf "$PROJECT_ROOT/backend"/.* 2>/dev/null || true
        echo "Backend directory cleared."
    fi
    
    # Clear frontend
    if [ -d "$PROJECT_ROOT/frontend" ]; then
        echo "Clearing frontend directory..."
        rm -rf "$PROJECT_ROOT/frontend"/*
        rm -rf "$PROJECT_ROOT/frontend"/.* 2>/dev/null || true
        echo "Frontend directory cleared."
    fi
    
    echo ""
    echo "Directories cleared. Run ./scripts/start-dev.sh to re-initialize."
else
    echo ""
    echo "To also clear backend and frontend directories, run with --clear flag:"
    echo "  ./stop-and-clear.sh --clear"
fi

echo ""
echo "========================================"
echo "Done!"
echo "========================================"
