#!/bin/bash
set -e  # Exit on error
set -x  # Enable debug output

# Get the directory containing the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the .env file to get USER variable
if [ -f "$SCRIPT_DIR/../.env" ]; then
    source "$SCRIPT_DIR/../.env"
else
    echo "Error: $SCRIPT_DIR/../.env file not found"
    exit 1
fi

# Check if USER variable is set
if [ -z "$USER" ]; then
    echo "Error: USER not defined in .env"
    exit 1
fi

# Check if we're running as the specified user
if [ "$(whoami)" != "$USER" ]; then
    echo "Switching to user: $USER"
    exec su - "$USER" -c "cd /home/$USER/src/tractstack-starter/scripts && ./storykeep-pull.sh"
fi

# If we're already the correct user
cd "/home/$USER/src/tractstack-starter/scripts" && ./storykeep-pull.sh
