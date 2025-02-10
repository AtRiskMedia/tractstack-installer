#!/bin/bash
set -e  # Exit on error

# ANSI color codes
blue='\033[0;34m'
red='\033[0;31m'
reset='\033[0m'

# Handle directory change based on argument (similar to build.sh)
if [ ! -z "$1" ]; then
    cd /home/"$1"
else
    cd ..
fi

# Check for and load environment variables (following build.sh pattern)
if [ -f ./.env ]; then
    USR_RAW=$(cat ./.env | grep USER)
    USR=$(echo "$USR_RAW" | sed 's/USER\=//g')
else
    echo -e "${red}FATAL ERROR: Tract Stack ~/.env with USER not found.${reset}"
    exit 1
fi

# Get current user
CURRENT_USER=$(whoami)

# Check if we're running as the specified user
if [ "$CURRENT_USER" != "$USR" ]; then
    echo -e "${blue}Switching to user: $USR${reset}"
    exec su - "$USR" -c "cd /home/$USR/src/tractstack-starter/scripts && ./storykeep-pull.sh"
fi

# If we're already the correct user, execute directly
echo -e "${blue}Running as $USR${reset}"
cd "/home/$USR/src/tractstack-starter/scripts" && ./storykeep-pull.sh
