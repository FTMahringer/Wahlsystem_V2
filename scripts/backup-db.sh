#!/bin/bash

# Backup MariaDB database

set -e

# Load environment variables
if [ -f "docker/prod/.env" ]; then
    export $(grep -v '^#' docker/prod/.env | xargs)
elif [ -f "docker/dev/.env" ]; then
    export $(grep -v '^#' docker/dev/.env | xargs)
else
    echo "Error: No .env file found!"
    exit 1
fi

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${PROJECT_NAME}_backup_${TIMESTAMP}.sql"

echo "Creating backup directory..."
mkdir -p $BACKUP_DIR

echo "Backing up MariaDB database..."
docker exec ${PROJECT_NAME}-mariadb mysqldump -u root -p${DB_ROOT_PASSWORD} ${DB_NAME} > $BACKUP_FILE

echo "Backup completed: $BACKUP_FILE"

# Compress backup
gzip $BACKUP_FILE
echo "Compressed: ${BACKUP_FILE}.gz"

# Remove backups older than 7 days
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete
echo "Old backups cleaned up."
