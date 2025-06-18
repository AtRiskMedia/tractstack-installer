#!/bin/bash
set -e # Exit on error

# Check if parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <backup_type> [user_directory]"
  echo ""
  echo "Backup types:"
  echo "  all - Backup both src and srv components"
  echo "  src - Backup only src components"
  echo "  srv - Backup only srv components"
  echo ""
  echo "Optional: Specify user directory as second parameter"
  exit 1
fi

BACKUP_TYPE="$1"
USER_DIR="$2"

# Validate backup type
if [ "$BACKUP_TYPE" != "all" ] && [ "$BACKUP_TYPE" != "src" ] && [ "$BACKUP_TYPE" != "srv" ]; then
  echo "ERROR: Invalid backup type '$BACKUP_TYPE'"
  echo "Valid options: all, src, srv"
  exit 1
fi

# Handle directory change based on second argument
if [ ! -z "$USER_DIR" ]; then
  cd /home/"$USER_DIR"
else
  cd ..
fi

# Check for and load environment variables
if [ -f ./.env ]; then
  USR_RAW=$(cat ./.env | grep USER)
  USR=$(echo "$USR_RAW" | sed 's/USER\=//g')
else
  echo "FATAL ERROR: Tract Stack ~/.env with USER not found."
  exit 1
fi

# Get current user
CURRENT_USER=$(whoami)

# Function to find additional directories in srv/public_html/storykeep (excluding symlinks)
find_srv_dirs() {
  if [ -d "srv/public_html/storykeep" ]; then
    find srv/public_html/storykeep -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read dir; do
      echo "$dir"
    done
  fi
}

# Function to find param directories that contain only [param1].astro
find_param_dirs() {
  find src/tractstack-storykeep/src/pages -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read dir; do
    # Count total files in directory
    file_count=$(find "$dir" -type f | wc -l)
    # Check if exactly one file and it's named [param1].astro
    if [ "$file_count" -eq 1 ] && [ -f "$dir/[param1].astro" ]; then
      echo "$dir"
    fi
  done
}

# Function to backup src components
backup_src() {
  echo "Creating src backup..."

  # Create backup directory if it doesn't exist
  mkdir -p /home/"$USR"/backup

  # Go to project root
  cd /home/"$USR"

  # Find param directories
  PARAM_DIRS=$(find_param_dirs)

  # Create the src backup - build tar command dynamically
  TAR_CMD="tar -czf /home/$USR/backup/${USR}_storykeep_src.tar.gz"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/config/*"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/custom"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/images"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/fonts"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/styles/custom.css"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/styles/app.css"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/styles/frontend.css"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/src/custom"

  # Add Dockerfile if it exists
  if [ -f "src/tractstack-storykeep/Dockerfile" ]; then
    TAR_CMD="$TAR_CMD src/tractstack-storykeep/Dockerfile"
    echo "Including Dockerfile"
  fi

  # Add .env if it exists
  if [ -f "src/tractstack-storykeep/.env" ]; then
    TAR_CMD="$TAR_CMD src/tractstack-storykeep/.env"
    echo "Including .env file"
  fi

  # Add param directories if any found
  if [ ! -z "$PARAM_DIRS" ]; then
    TAR_CMD="$TAR_CMD $PARAM_DIRS"
    echo "Including param directories: $PARAM_DIRS"
  fi

  # Execute the tar command
  eval $TAR_CMD

  echo "Src backup created: /home/$USR/backup/${USR}_storykeep_src.tar.gz"
}

# Function to backup srv components
backup_srv() {
  echo "Creating srv backup..."

  # Create backup directory if it doesn't exist
  mkdir -p /home/"$USR"/backup

  # Go to project root
  cd /home/"$USR"

  # Find additional srv directories (excluding symlinks)
  SRV_DIRS=$(find_srv_dirs)

  # Check if there are srv directories to backup
  if [ -z "$SRV_DIRS" ]; then
    echo "No srv directories found to backup"
    return
  fi

  # Create the srv backup
  TAR_CMD="tar -czf /home/$USR/backup/${USR}_storykeep_srv.tar.gz $SRV_DIRS"
  echo "Including srv directories: $SRV_DIRS"

  # Execute the tar command
  eval $TAR_CMD

  echo "Srv backup created: /home/$USR/backup/${USR}_storykeep_srv.tar.gz"
}

# Function to perform the backup based on type
do_backup() {
  case "$BACKUP_TYPE" in
  "all")
    echo "Performing full backup (src and srv)..."
    backup_src
    backup_srv
    ;;
  "src")
    echo "Performing src-only backup..."
    backup_src
    ;;
  "srv")
    echo "Performing srv-only backup..."
    backup_srv
    ;;
  esac
}

# Check if we're running as the specified user
if [ "$CURRENT_USER" != "$USR" ]; then
  echo "Switching to user: $USR"
  exec su - "$USR" -c "cd /home/$USR/scripts && ./backup.sh $BACKUP_TYPE"
else
  echo "Running as $USR"
  do_backup
fi
