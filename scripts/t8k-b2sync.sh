#!/bin/bash
# Ensure we're running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

# Source B2 configuration
if [ ! -f "/home/t8k/.env.b2" ]; then
    echo "B2 configuration file not found!"
    exit 1
fi
source /home/t8k/.env.b2

# Verify required variables
if [ -z "$B2_BUCKET_NAME" ]; then
    echo "B2_BUCKET_NAME not set in .env.b2"
    exit 1
fi

# Get backup type from argument
BACKUP_TYPE=$1
if [[ -z "$BACKUP_TYPE" ]]; then
    echo "Usage: $0 <hourly|daily|weekly|monthly>"
    exit 1
fi

# Ensure backup directory exists
if [ ! -d "/home/t8k/backup" ]; then
    echo "Backup directory not found!"
    exit 1
fi

# Log function with timestamps
log_message() {
    local level=$1
    local message=$2
    logger -t "tractstack-b2sync" "$level: $message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level]: $message"
}

# Check rclone config exists
RCLONE_CONFIG="/home/t8k/.config/rclone/rclone.conf"
if [ ! -f "$RCLONE_CONFIG" ]; then
    log_message "ERROR" "Rclone config not found in $RCLONE_CONFIG"
    exit 1
fi

# Test rclone configuration using root with t8k's config
log_message "INFO" "Testing rclone configuration..."
if ! RCLONE_CONFIG="$RCLONE_CONFIG" rclone lsd tractstack-b2: >/dev/null 2>&1; then
    log_message "ERROR" "Failed to access B2 bucket. Please check rclone configuration."
    log_message "INFO" "Run 'sudo -u t8k rclone config' to reconfigure."
    exit 1
fi

# Sync function with improved error handling
sync_to_b2() {
    local source_dir="$1"
    local b2_path="$2"
    
    if [ ! -d "$source_dir" ]; then
        log_message "WARN" "Source directory $source_dir does not exist, skipping"
        return 0
    fi

    log_message "INFO" "Starting sync of $source_dir to B2"
    
    # Create temporary file for rclone output
    local temp_log=$(mktemp)
    
    # Run rclone as root but using t8k's config
    if RCLONE_CONFIG="$RCLONE_CONFIG" rclone sync "$source_dir" "tractstack-b2:$B2_BUCKET_NAME/$b2_path" \
        --transfers 32 \
        --checkers 16 \
        --stats 30s \
        --stats-one-line \
        --log-level INFO \
        --log-file="$temp_log"; then
        
        log_message "INFO" "Successfully synced $source_dir to B2"
        
        # Log transfer statistics
        local transferred=$(grep "Transferred:" "$temp_log" | tail -n1)
        log_message "INFO" "Transfer stats: $transferred"
    else
        local error_code=$?
        log_message "ERROR" "Failed to sync $source_dir to B2 (exit code: $error_code)"
        
        # Log the last few lines of the error output
        log_message "ERROR" "Last rclone errors:"
        tail -n 5 "$temp_log" | while read -r line; do
            log_message "ERROR" "$line"
        done
    fi
    
    # Cleanup
    rm -f "$temp_log"
}

# Sync based on backup type
case "$BACKUP_TYPE" in
    "hourly")
        sync_to_b2 "/home/t8k/backup/hourly.0" "hourly.0"
        sync_to_b2 "/home/t8k/backup/hourly.1" "hourly.1"
        ;;
    "daily")
        sync_to_b2 "/home/t8k/backup/daily.0" "daily.0"
        sync_to_b2 "/home/t8k/backup/daily.1" "daily.1"
        ;;
    "weekly")
        sync_to_b2 "/home/t8k/backup/weekly.0" "weekly.0"
        sync_to_b2 "/home/t8k/backup/weekly.1" "weekly.1"
        ;;
    "monthly")
        sync_to_b2 "/home/t8k/backup/monthly.0" "monthly.0"
        sync_to_b2 "/home/t8k/backup/monthly.1" "monthly.1"
        ;;
    *)
        log_message "ERROR" "Invalid backup type: $BACKUP_TYPE"
        exit 1
        ;;
esac
