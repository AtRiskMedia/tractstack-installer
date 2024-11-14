#!/bin/bash

TARGET=$2
if [[ -z "$TARGET" ]]; then
  NAME=$1
  INSTALL_USER=$1
elif [[ "$TARGET" == "features" || "$TARGET" == "sandbox" ]]; then
  NAME="$2"_"$1"
  INSTALL_USER="t8k"
fi

blue='\033[0;34m'
brightblue='\033[1;34m'
white='\033[1;37m'
reset='\033[0m'

echo -e "${brightblue}"
echo -e "${brightblue}  _                ${blue}  _       _             _     "
echo -e "${brightblue} | |_ _ __ __ _  ___| |_ ${blue}___| |_ __ _  ___| | __ "
echo -e "${brightblue} | __| \__/ _\` |/ __| __/ ${blue}__| __/ _\` |/ __| |/ / "
echo -e "${brightblue} | |_| | | (_| | (__| |_${blue}\__ \ || (_| | (__|   <  "
echo -e "${brightblue}  \__|_|  \__,_|\___|\__|${blue}___/\__\__,_|\___|_|\_\ "
echo -e ""
echo -e "${reset}no-code website builder and content marketing platform"
echo -e "${white}by At Risk Media"
echo -e "${reset}"

if [ "$NAME" == "$INSTALL_USER" ]; then
  if [ ! -d /home/"$NAME" ]; then
    echo User "$NAME" does not already exist.
    echo ""
    exit 1
  fi
else
  if [ ! -d /home/t8k/"$TARGET"/"$NAME" ]; then
    echo User "$NAME" does not already exist in "$TARGET".
    echo ""
    exit 1
  fi
fi

if [ "$NAME" = "" ]; then
  echo To upgrade Tract Stack provide linux user name
  echo Usage: sudo ./tractstack-pull.sh username
  echo ""
  exit 1
fi

if [ "$USER" != root ]; then
  echo Must provide sudo privileges
  echo ""
  exit 1
fi

echo ""
echo Upgrading Tract Stack as user: "$NAME"
echo *** must implement upgrade of tractstack-storykeep via tractstack-starter
if [ "$NAME" == "$INSTALL_USER" ]; then
  #sudo -H -u "$NAME" bash -c 'cd ~/src/tractstack-storykeep; git pull'
  sudo -H -u "$NAME" bash -c 'cd ~/src/tractstack-starter; git pull'
  sudo -H -u "$NAME" bash -c 'cd ~/srv/tractstack-concierge; git pull'
else
  #sudo -H -u "$NAME" bash -c 'cd ~/"$TARGET"/"$USER"/src/tractstack-storykeep; git pull'
  sudo -H -u "$NAME" bash -c 'cd ~/"$TARGET"/"$USER"/src/tractstack-starter; git pull'
  sudo -H -u "$NAME" bash -c 'cd ~/"$TARGET"/"$USER"/srv/tractstack-concierge; git pull'
fi
