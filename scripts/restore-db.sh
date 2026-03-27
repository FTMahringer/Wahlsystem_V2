#!/bin/bash

# Restore MariaDB database from backup

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 ./backups/myapp_backup_20240101_120000.sql.gz"
    exit 1
fi

BACKUP_FILE=$1

# Load environment variables
if [ -f "docker/prod/.env" ]; then
    export $(grep -v '^#' docker/prod/.env | xargs)
elif [ -f "docker/dev/.env" ]; then
    export $(grep -v '^#' docker/dev/.env | xargs)
else
    echo "Error: No .env file found!"
    exit 1
fi

echo "WARNING: This will overwrite the current database!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Decompress if needed
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "Decompressing backup..."
    gunzip -c $BACKUP_FILE > /tmp/restore.sql
    BACKUP_FILE="/tmp/restore.sql"
fi

echo "Restoring database..."
docker exec -i ${PROJECT_NAME}-mariadb mysql -u root -p${DB_ROOT_PASSWORD} ${DB_NAME} < $BACKUP_FILE

echo "Restore completed!"

# Cleanup
if [ -f "/tmp/restore.sql" ]; then
    rm /tmp/restore.sql
fi
