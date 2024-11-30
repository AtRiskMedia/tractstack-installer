#!/bin/bash

# Get list of users from .env.backups
while IFS= read -r user; do
  # Skip empty lines
  [ -z "$user" ] && continue

  # Check if user's .env exists
  ENV_FILE="/home/$user/srv/tractstack-concierge/.env"
  if [ ! -f "$ENV_FILE" ]; then
    continue
  fi

  # Extract database credentials
  DB_NAME="concierge_$user"
  DB_PASS=$(grep DB_PASSWORD "$ENV_FILE" | cut -d'=' -f2 | tr -d '"')

  # Ensure backup directory exists
  BACKUP_DIR="/home/$user/backup"
  mkdir -p "$BACKUP_DIR"

  # Perform backup with proper ownership
  mysqldump --single-transaction "$DB_NAME" >"$BACKUP_DIR/mysql-backup.sql"
  chown "$user":www-data "$BACKUP_DIR/mysql-backup.sql"
  chmod 640 "$BACKUP_DIR/mysql-backup.sql"
done </home/t8k/.env.backups
