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

if [ "$NAME" = "" ]; then
	echo To install Tract Stack provide linux user name
	echo Usage: sudo ./tractstack-install.sh username
	echo ""
	exit
fi

if [ "$USER" != root ]; then
	echo Must provide sudo privileges
	echo ""
	exit
fi

echo ""
echo Installing Tract Stack as user: "$NAME"
useradd -m "$NAME"
mkdir /home/"$NAME"/scripts
cp ./tractstack-home-init.sh /home/"$NAME"/scripts/
cp ./tractstack-init-drupal.sh /home/"$NAME"/scripts/
sudo -H -u "$NAME" bash -c '~/scripts/tractstack-home-init.sh'
sudo -H -u "$NAME" bash -c '~/scripts/tractstack-init-drupal.sh'
cp ../files/web.config /home/"$NAME"/srv/public_html/drupal/oauth_keys
./fix-drupal.sh /home/"$NAME"/srv/public_html/drupal/web "$NAME"
