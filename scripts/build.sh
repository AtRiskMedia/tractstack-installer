#!/bin/bash

if [ ! -z $1 ]; then
  echo cd /home/"$1"
  cd /home/"$1"
else
  cd ..
fi

if [ -f ./.env ]; then
  NAME_RAW=$(cat ./.env | grep NAME)
  NAME=$(echo "$NAME_RAW" | sed 's/NAME\=//g')
  USR_RAW=$(cat ./.env | grep USER)
  USR=$(echo "$USR_RAW" | sed 's/USER\=//g')
  PORT_RAW=$(cat ./.env | grep PORT)
  PORT=$(echo "$PORT_RAW" | sed 's/PORT\=//g')
else
  echo "FATAL ERROR: Tract Stack ~/.env with NAME and USER not found."
  exit
fi

SITENAME="tractstack"
NOW=$(date +%s)
RAN=false

# Get current lastBuild from existing build.json if it exists
if [ -f /home/"$USR"/srv/tractstack-concierge/api/build.json ]; then
  LAST_BUILD=$(cat /home/"$USR"/srv/tractstack-concierge/api/build.json | grep -o '"lastBuild":[0-9]*' | grep -o '[0-9]*')
else
  LAST_BUILD=$NOW
fi
echo "{\"status\":\"building\",\"lastBuild\":$LAST_BUILD,\"now\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json

blue='\033[0;34m'
brightblue='\033[1;34m'
white='\033[1;37m'
reset='\033[0m'

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

cd /home/"$USR"/src/tractstack-storykeep

RUNNING=$(docker ps -q --filter ancestor=tractstack-storykeep-"$USR")
sudo docker build --network=host -t tractstack-storykeep-"$USR" .
if [ ! -z "$RUNNING" ]; then
  sudo docker stop "$RUNNING"
  sudo docker rm "$RUNNING"
  sudo docker ps
else
  echo * new container
fi
sudo docker run --net=host -d --restart unless-stopped tractstack-storykeep-"$USR"
RUNNING_IMAGE=$(docker images -q tractstack-storykeep-"$USR" --filter "dangling=true" --no-trunc)
if [ ! -z "$RUNNING_IMAGE" ]; then
  sudo docker rmi "$RUNNING_IMAGE"
fi
echo -e "${blue}done.${reset}"

rm /home/"$USR"/watch/build.lock 2>/dev/null || true

# Update build status on success
echo "{\"status\":\"active\",\"lastBuild\":$NOW}" >/home/"$USR"/srv/tractstack-concierge/api/build.json
