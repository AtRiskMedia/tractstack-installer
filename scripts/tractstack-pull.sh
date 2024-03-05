#!/bin/bash

NAME=$1

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
echo -e "${reset}All-in-one customer journey analytics web funnels builder"
echo -e "${white}by At Risk Media"
echo -e "${reset}"

if [ ! -d /home/"$NAME" ]; then
	echo User "$NAME" not found.
	echo ""
	exit 1
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
sudo -H -u "$NAME" bash -c 'cd ~/src/gatsby-starter-storykeep; git pull'
sudo -H -u "$NAME" bash -c 'cd ~/src/gatsby-starter-tractstack; git pull'
sudo -H -u "$NAME" bash -c 'cd ~/srv/tractstack-concierge; git pull'
