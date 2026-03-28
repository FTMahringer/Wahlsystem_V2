#!/bin/bash

# Wipe Frontend - Clears all contents from the frontend folder but keeps the directory
# Usage: ./wipe-frontend.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

echo "========================================"
echo "Wiping Frontend Contents"
echo "========================================"

if [ -d "$FRONTEND_DIR" ]; then
    echo "Clearing frontend directory: $FRONTEND_DIR"
    # Remove all contents but keep the directory itself
    rm -rf "$FRONTEND_DIR"/*
    rm -rf "$FRONTEND_DIR"/.* 2>/dev/null || true
    echo "Frontend directory cleared successfully."
else
    echo "Frontend directory does not exist. Creating empty directory..."
    mkdir -p "$FRONTEND_DIR"
    echo "Empty frontend directory created."
fi

echo "========================================"
echo "Done!"
echo "========================================"
