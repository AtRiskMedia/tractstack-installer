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
reset='\033[0m'

# Display ASCII art header
echo -e "${brightblue}"
echo -e "${brightblue}  _                ${blue}  _       _             _     "
echo -e "${brightblue} | |_ _ __ __ _  ___| |_ ${blue}___| |_ __ _  ___| | __ "
echo -e "${brightblue} | __| \__/ _\` |/ __| __/ ${blue}__| __/ _\` |/ __| |/ / "
echo -e "${brightblue} | |_| | | (_| | (__| |_\__ ${blue}\ || (_| | (__|   <  "
echo -e "${brightblue}  \__|_|  \__,_|\___|\__|${blue}___/\__\__,_|\___|_|\_\ "
echo -e ""
echo -e "${white}  free web press ${reset}by At Risk Media"
echo ""
echo -e "building ${white}$SITENAME (frontend)${reset}"

# Change to project directory
cd /home/"$USR"/src/tractstack-storykeep

# Build the new image
echo "Building new image..."
if ! sudo docker build --network=host -t tractstack-storykeep-"$USR" .; then
  echo "Build failed."
  echo "{\"status\":\"failed\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
  exit 1
fi

# After successful build, stop the old container
echo "Stopping old container..."
RUNNING_CONTAINER=$(sudo docker ps --filter ancestor=tractstack-storykeep-"$USR" -q | head -n 1)
if [ ! -z "$RUNNING_CONTAINER" ]; then
  sudo docker stop "$RUNNING_CONTAINER" >/dev/null 2>&1
  sudo docker rm "$RUNNING_CONTAINER" >/dev/null 2>&1
fi

# Generate new container name
CONTAINER_NAME="tractstack-storykeep-$USR-$(date +%s)"

# Check if container with this name already exists and remove it
if sudo docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "Container with name $CONTAINER_NAME already exists, removing it..."
  sudo docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
fi

# Start new container and capture its ID
echo "Starting new container..."
if ! NEW_CONTAINER=$(sudo docker run \
  --net=host \
  -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -v /home/$USR/src/tractstack-storykeep/public:/app/public \
  -v /home/$USR/src/tractstack-storykeep/config:/app/config \
  tractstack-storykeep-"$USR"); then
  echo "Failed to start new container"
  echo "{\"status\":\"failed\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
  exit 1
fi

# Verify new container is running
if [ ! -z "$(sudo docker ps -q -f id=$NEW_CONTAINER)" ]; then
  # Clean up any other stopped containers for this image
  echo "Cleaning up any stopped containers..."
  STOPPED_CONTAINERS=$(sudo docker ps -a --filter ancestor=tractstack-storykeep-"$USR" -q | grep -v "$NEW_CONTAINER")
  if [ ! -z "$STOPPED_CONTAINERS" ]; then
    echo "$STOPPED_CONTAINERS" | while read container; do
      [ "$container" != "$NEW_CONTAINER" ] && sudo docker rm "$container" >/dev/null 2>&1
    done
  fi

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
