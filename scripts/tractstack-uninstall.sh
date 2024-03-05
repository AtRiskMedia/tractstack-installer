#!/bin/bash

NAME=$1
DB_NAME=t8k_"$NAME"
CONCIERGE_DB_NAME=concierge_"$NAME"

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
	echo User "$NAME" does not already exist.
	echo ""
	exit 1
fi

if [ "$NAME" = "" ]; then
	echo To uninstall Tract Stack provide linux user name
	echo Usage: sudo ./tractstack-uninstall.sh username
	echo ""
	exit 1
fi

if [ "$USER" != root ]; then
	echo Must provide sudo privileges
	echo ""
	exit 1
fi

echo ""
echo Dropping drupal database and user: t8k_"$NAME"
mysql -e "DROP DATABASE ${DB_NAME};" >/dev/null 2>&1
mysql -e "DROP USER ${DB_NAME}@localhost;" >/dev/null 2>&1
echo ""
echo Dropping Concierge database: concierge_"$NAME"
mysql -e "DROP DATABASE ${CONCIERGE_DB_NAME};" >/dev/null 2>&1
mysql -e "FLUSH PRIVILEGES;" >/dev/null 2>&1

echo ""
echo Removing Tract Stack for user: "$NAME"
deluser "$NAME"
rm -rf /home/"$NAME"

#echo ""
#echo Remove certificate
#rm -rf /etc/letsencrypt/*/"$NAME".tractstack.com*

echo ""
echo Removing nginx config for "$NAME".tractstack.com and storykeep."$NAME".tractstack.com
rm /etc/nginx/sites-available/storykeep."$NAME".conf
rm /etc/nginx/sites-available/t8k."$NAME".conf
rm /etc/nginx/sites-enabled/storykeep."$NAME".conf
rm /etc/nginx/sites-enabled/t8k."$NAME".conf
if ! nginx -t 2>/dev/null; then
	echo ""
	echo Fatal Error removing Nginx config! UNSAFE CONFIG!!!
	echo ""
	exit 1
fi
service nginx reload

echo ""
echo Disable log rotation
rm /etc/logrotate.d/nginx."$NAME"

echo ""
echo Remove systemd path unit - build watch
systemctl stop t8k-"$NAME".path
systemctl disable t8k-"$NAME".path
rm /etc/systemd/system/t8k-"$NAME".path
rm /etc/systemd/system/t8k-"$NAME".service
