#!/bin/bash

# Wipe Backend - Clears all contents from the backend folder but keeps the directory
# Usage: ./wipe-backend.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"

echo "========================================"
echo "Wiping Backend Contents"
echo "========================================"

if [ -d "$BACKEND_DIR" ]; then
    echo "Clearing backend directory: $BACKEND_DIR"
    # Remove all contents but keep the directory itself
    rm -rf "$BACKEND_DIR"/*
    rm -rf "$BACKEND_DIR"/.* 2>/dev/null || true
    echo "Backend directory cleared successfully."
else
    echo "Backend directory does not exist. Creating empty directory..."
    mkdir -p "$BACKEND_DIR"
    echo "Empty backend directory created."
fi

echo "========================================"
echo "Done!"
echo "========================================"
