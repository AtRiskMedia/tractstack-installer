#!/bin/bash

TARGET=$2
echo "$TARGET"
if [[ -z "$TARGET" ]]; then
  NAME=$1
  INSTALL_USER=$1
  ID="$1"
elif [[ "$TARGET" == "features" || "$TARGET" == "sandbox" ]]; then
  NAME="$2"_"$1"
  INSTALL_USER="t8k"
  ID="$2"-"$1"
else
  echo To uninstall Tract Stack from a target environment, please specific features or sandbox
  echo Usage: sudo ./tractstack-uninstall.sh username target
  echo ELSE for user install... Usage: sudo ./tractstack-uninstall.sh username
  echo ""
  exit 1
fi

CONCIERGE_DB_NAME=concierge_"$NAME"
CONCIERGE_DB_USER=t8k_"$NAME"

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

if [ "$NAME" == "t8k" ]; then
  echo "Cannot uninstall primary t8k user; did you mean to?"
  exit
fi

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
  echo To uninstall Tract Stack provide linux user name
  echo Usage: sudo ./tractstack-uninstall.sh username
  echo ""
  echo To uninstall Tract Stack from a target environment, please specific features or sandbox
  echo Usage: sudo ./tractstack-uninstall.sh username target
  echo ""
  exit 1
fi

if [ "$USER" != root ]; then
  echo Must provide sudo privileges
  echo ""
  exit 1
fi

RUNNING=$(docker ps -q --filter ancestor=tractstack-storykeep-"$ID")
if [ ! -z "$RUNNING" ]; then
  echo ""
  echo Stopping Docker
  sudo docker stop "$RUNNING"
  sudo docker rm "$RUNNING"
fi

echo ""
echo Cancelling port reservation
cp /home/t8k/.env /home/t8k/.env.bak
grep -v "^PORT_""$NAME" /home/t8k/.env.bak >/home/t8k/.env

echo ""
echo Dropping Concierge database: concierge_"$NAME"
mysql -e "DROP DATABASE ${CONCIERGE_DB_NAME};" >/dev/null 2>&1
mysql -e "DROP USER '${CONCIERGE_DB_USER}'@'localhost';" >/dev/null 2>&1
echo "DROP DATABASE ${CONCIERGE_DB_NAME};"
echo "DROP USER '${CONCIERGE_DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;" >/dev/null 2>&1

if [ "$NAME" == "$INSTALL_USER" ]; then
  echo ""
  echo Removing Tract Stack for user: "$NAME"
  deluser "$NAME"
  rm -rf /home/"$NAME"
else
  echo ""
  echo Removing Tract Stack for user: "$NAME" in "$TARGET"
  rm -rf /home/t8k/"$TARGET"/"$NAME"
fi

#echo ""
#echo Remove certificate
#rm -rf /etc/letsencrypt/*/"$NAME".tractstack.com*

if [ "$NAME" == "$INSTALL_USER" ]; then
    echo ""
    echo "Removing backup configuration"
    
    # Remove from backups list
    sed -i "/^$NAME$/d" /home/t8k/.env.backups
    
    # Remove backup directory
    rm -rf /home/t8k/backup/"$NAME"
    
    # Remove from rsnapshot config
    sed -i "/backup.*\/$NAME\//d" /etc/rsnapshot.conf
    
    # Check if this was the last backup user
    if [ ! -s /home/t8k/.env.backups ]; then
        # Stop and remove systemd timers
        systemctl stop t8k-backup.timer
        systemctl disable t8k-backup.timer
        systemctl stop t8k-backup-hourly.timer 2>/dev/null || true
        systemctl disable t8k-backup-hourly.timer 2>/dev/null || true
        rm -f /etc/systemd/system/t8k-backup*
        
        # Remove rsnapshot config
        rm -f /etc/rsnapshot.conf
    fi
fi

if [ "$NAME" == "$INSTALL_USER" ]; then
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
else
  echo ""
  echo Removing nginx config for "$TARGET"."$1".tractstack.com and "$TARGET".storykeep."$1".tractstack.com
  rm /etc/nginx/sites-available/"$TARGET".storykeep."$1".conf
  rm /etc/nginx/sites-available/"$TARGET".t8k."$1".conf
  rm /etc/nginx/sites-enabled/"$TARGET".storykeep."$1".conf
  rm /etc/nginx/sites-enabled/"$TARGET".t8k."$1".conf
  if ! nginx -t 2>/dev/null; then
    echo ""
    echo Fatal Error removing Nginx config! UNSAFE CONFIG!!!
    echo ""
    exit 1
  fi
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
