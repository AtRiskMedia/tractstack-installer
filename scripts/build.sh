#!/bin/bash

# Handle directory change based on argument
if [ ! -z $1 ]; then
  echo cd /home/"$1"
  cd /home/"$1"
else
  cd ..
fi

# Check for and load environment variables
if [ -f ./.env ]; then
  NAME_RAW=$(cat ./.env | grep NAME)
  NAME=$(echo "$NAME_RAW" | sed 's/NAME\=//g')
  USR_RAW=$(cat ./.env | grep USER)
  USR=$(echo "$USR_RAW" | sed 's/USER\=//g')
  PORT_RAW=$(cat ./.env | grep PORT)
  PORT=$(echo "$PORT_RAW" | sed 's/PORT\=//g')
else
  echo "FATAL ERROR: Tract Stack ~/.env with NAME and USER not found."
  exit 1
fi

SITENAME="tractstack"
NOW=$(date +%s)

# Get current lastBuild from existing build.json if it exists
if [ -f /home/"$USR"/srv/tractstack-concierge/api/build.json ]; then
  LAST_BUILD=$(cat /home/"$USR"/srv/tractstack-concierge/api/build.json | grep -o '"lastBuild":[0-9]*' | grep -o '[0-9]*')
else
  LAST_BUILD=$NOW
fi

# Update build status to building
echo "{\"status\":\"building\",\"lastBuild\":$LAST_BUILD,\"now\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json

# Define colors for output
blue='\033[0;34m'
brightblue='\033[1;34m'
white='\033[1;37m'
green='\033[0;32m'
reset='\033[0m'

# Display ASCII art header
echo -e "${brightblue}"
echo -e "    ███        ▄████████    ▄████████  ▄████████     ███    "
echo -e "▀█████████▄   ███    ███   ███    ███ ███    ███ ▀█████████▄"
echo -e "   ▀███▀▀██   ███    ███   ███    ███ ███    █▀     ▀███▀▀██"
echo -e "    ███   ▀  ▄███▄▄▄▄██▀   ███    ███ ███            ███   ▀"
echo -e "    ███     ▀▀███▀▀▀▀▀   ▀███████████ ███            ███    "
echo -e "    ███     ▀███████████   ███    ███ ███    █▄      ███    "
echo -e "    ███       ███    ███   ███    ███ ███    ███     ███    "
echo -e "   ▄████▀     ███    ███   ███    █▀  ████████▀     ▄████▀  "
echo -e "              ███    ███                                    "
echo -e "${blue}"
echo -e "   ▄████████     ███        ▄████████  ▄████████    ▄█   ▄█▄"
echo -e "  ███    ███ ▀█████████▄   ███    ███ ███    ███   ███ ▄███▀"
echo -e "  ███    █▀     ▀███▀▀██   ███    ███ ███    █▀    ███▐██▀  "
echo -e "  ███            ███   ▀   ███    ███ ███         ▄█████▀   "
echo -e "▀███████████     ███     ▀███████████ ███        ▀▀█████▄   "
echo -e "         ███     ███       ███    ███ ███    █▄    ███▐██▄  "
echo -e "   ▄█    ███     ███       ███    ███ ███    ███   ███ ▀███▄"
echo -e " ▄████████▀     ▄████▀     ███    █▀  ████████▀    ███   ▀█▀"
echo -e "                                                   ▀        "
echo -e "${white}  no-code build your own funnel website"
echo -e "${reset}  by At Risk Media"
echo ""

# Check build.lock content and perform pulls if needed
if [ -f /home/"$USR"/watch/build.lock ]; then
  BUILD_TARGET=$(cat /home/"$USR"/watch/build.lock)

  case "$BUILD_TARGET" in
  "all")
    echo -e "${green}Pulling latest changes for both concierge and storykeep...${reset}"
    # Pull concierge
    /home/"$USR"/scripts/pull-concierge.sh "$USR"
    # Pull storykeep
    /home/"$USR"/scripts/pull.sh "$USR"
    ;;
  "concierge")
    echo -e "${green}Pulling latest changes for concierge only...${reset}"
    /home/"$USR"/scripts/pull-concierge.sh "$USR"
    ;;
  "storykeep")
    echo -e "${green}Pulling latest changes for storykeep only...${reset}"
    /home/"$USR"/scripts/pull.sh "$USR"
    ;;
  *)
    echo -e "No pull requested, proceeding with build only"
    ;;
  esac
fi

echo -e "building ${white}$SITENAME (frontend)${reset}"

# Change to project directory
cd /home/"$USR"/src/tractstack-storykeep

# Ensure directories exist
mkdir -p /home/"$USR"/src/tractstack-storykeep/public
mkdir -p /home/"$USR"/src/tractstack-storykeep/config

# Build the new image
echo "Building new image..."
if ! sudo docker build --network=host -t tractstack-storykeep-"$USR" .; then
  echo "Build failed."
  echo "{\"status\":\"failed\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
  exit 1
fi

# Stop and remove all existing containers with our name pattern
echo "Cleaning up existing containers..."
for attempt in {1..3}; do
  # Get all containers matching our name pattern (both running and stopped)
  EXISTING_CONTAINERS=$(sudo docker ps -a --format '{{.Names}}' | grep "tractstack-storykeep-$USR" || true)
  if [ ! -z "$EXISTING_CONTAINERS" ]; then
    # Force stop and remove all matching containers
    echo "$EXISTING_CONTAINERS" | while read container; do
      echo "Stopping and removing $container"
      sudo docker stop -t 0 "$container" 2>/dev/null || true
      sudo docker rm -f "$container" 2>/dev/null || true
    done
  fi

  # Double check nothing is left
  REMAINING=$(sudo docker ps -a --format '{{.Names}}' | grep "tractstack-storykeep-$USR" || true)
  if [ -z "$REMAINING" ]; then
    echo "All containers cleaned up successfully"
    break
  fi

  echo "Retrying cleanup... (attempt $attempt)"
  sleep 1
done

# Final verification
if [ ! -z "$(sudo docker ps -a --format '{{.Names}}' | grep "tractstack-storykeep-$USR" || true)" ]; then
  echo "Failed to clean up all containers"
  exit 1
fi

# Generate new container name with timestamp
CONTAINER_NAME="tractstack-storykeep-$USR-$(date +%s)"

# Start new container with bind mounts
echo "Starting new container..."
if ! NEW_CONTAINER=$(sudo docker run \
  --net=host \
  -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -v /home/$USR/src/tractstack-storykeep/public:/app/public \
  -v /home/$USR/src/tractstack-storykeep/config:/app/config \
  -v /home/$USR/src/tractstack-storykeep/.env:/app/.env \
  -v /home/$USR/tenants:/tenants \
  tractstack-storykeep-"$USR"); then
  echo "Failed to start new container"
  echo "{\"status\":\"failed\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
  exit 1
fi

# Verify new container is running
if [ ! -z "$(sudo docker ps -q -f id=$NEW_CONTAINER)" ]; then
  # Clean up any dangling images
  DANGLING_IMAGES=$(sudo docker images -q tractstack-storykeep-"$USR" --filter "dangling=true" --no-trunc)
  if [ ! -z "$DANGLING_IMAGES" ]; then
    echo "Cleaning up old images..."
    echo "$DANGLING_IMAGES" | while read image; do
      sudo docker rmi "$image" >/dev/null 2>&1
    done
  fi
  echo "Successfully deployed new container"
else
  echo "New container failed to start. Please check logs with: docker logs $NEW_CONTAINER"
  echo "{\"status\":\"failed\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
  exit 1
fi

echo -e "${blue}done.${reset}"

# Remove build lock file if it exists
rm /home/"$USR"/watch/build.lock 2>/dev/null || true

# Update build status on success
echo "{\"status\":\"active\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
