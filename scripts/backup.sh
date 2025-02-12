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

# Function to perform the backup
do_backup() {
  # Create backup directory if it doesn't exist
  mkdir -p /home/"$USR"/backup

  # Go to project root
  cd /home/"$USR"

  # Create the backup
  tar -czf /home/"$USR"/backup/"$USR"_storykeep.tar.gz \
    src/tractstack-storykeep/config/* \
    src/tractstack-storykeep/public/custom \
    src/tractstack-storykeep/public/images \
    src/tractstack-storykeep/public/styles/app.css \
    src/tractstack-storykeep/public/styles/frontend.css \
    src/tractstack-storykeep/src/custom

  echo "Backup created: /home/$USR/backup/${USR}_storykeep.tar.gz"
}

# Check if we're running as the specified user
if [ "$CURRENT_USER" != "$USR" ]; then
  echo "Switching to user: $USR"
  exec su - "$USR" -c "cd /home/$USR/src/tractstack-starter/scripts && ./backup.sh"
else
  echo "Running as $USR"
  do_backup
fi
