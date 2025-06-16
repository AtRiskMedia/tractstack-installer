#!/bin/bash
set -e # Exit on error

# Handle directory change based on argument
if [ ! -z "$1" ]; then
  cd /home/"$1"
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

# Function to perform the backup
do_backup() {
  # Create backup directory if it doesn't exist
  mkdir -p /home/"$USR"/backup

  # Go to project root
  cd /home/"$USR"

  # Find param directories
  PARAM_DIRS=$(find_param_dirs)

  # Find additional srv directories (excluding symlinks)
  SRV_DIRS=$(find_srv_dirs)

  # Create the backup - build tar command dynamically
  TAR_CMD="tar -czf /home/$USR/backup/${USR}_storykeep.tar.gz"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/config/*"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/custom"
  TAR_CMD="$TAR_CMD src/tractstack-storykeep/public/images"
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

  # Add srv directories if any found
  if [ ! -z "$SRV_DIRS" ]; then
    TAR_CMD="$TAR_CMD $SRV_DIRS"
    echo "Including srv directories: $SRV_DIRS"
  fi

  # Execute the tar command
  eval $TAR_CMD

  echo "Backup created: /home/$USR/backup/${USR}_storykeep.tar.gz"
}

# Check if we're running as the specified user
if [ "$CURRENT_USER" != "$USR" ]; then
  echo "Switching to user: $USR"
  exec su - "$USR" -c "cd /home/$USR/scripts && ./backup.sh"
else
  echo "Running as $USR"
  do_backup
fi
