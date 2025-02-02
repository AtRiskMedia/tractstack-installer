#!/bin/bash

ENHANCED_BACKUPS=true

NAME=$1
INSTALL_USER=$1
ID="$1"

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
echo -e "${white}  free web press ${reset}by At Risk Media"
echo ""

if [ "$NAME" == "t8k" ]; then
  echo "Cannot uninstall primary t8k user; did you mean to?"
  exit
fi

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
echo Removing Tract Stack for user: "$NAME"
deluser "$NAME"
rm -rf /home/"$NAME"

#echo ""
#echo Remove certificate
#rm -rf /etc/letsencrypt/*/"$NAME".tractstack.com*

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
  systemctl stop t8k-mysql-backup.timer 2>/dev/null || true
  systemctl disable t8k-mysql-backup.timer 2>/dev/null || true
  systemctl stop t8k-mysql-backup-weekly.timer 2>/dev/null || true
  systemctl disable t8k-mysql-backup-weekly.timer 2>/dev/null || true
  rm -f /etc/systemd/system/t8k-mysql-backup*
  # Remove rsnapshot config
  rm -f /etc/rsnapshot.conf
fi

echo ""
echo "Removing B2 sync systemd units"
if [ "$ENHANCED_BACKUPS" = true ]; then
  systemctl stop t8k-b2sync-hourly.timer
  systemctl disable t8k-b2sync-hourly.timer
  systemctl stop t8k-b2sync-daily.timer
  systemctl disable t8k-b2sync-daily.timer
  systemctl stop t8k-b2sync-weekly.timer
  systemctl disable t8k-b2sync-weekly.timer
  systemctl stop t8k-b2sync-monthly.timer
  systemctl disable t8k-b2sync-monthly.timer
  rm -f /etc/systemd/system/t8k-b2sync-hourly.service
  rm -f /etc/systemd/system/t8k-b2sync-hourly.timer
  rm -f /etc/systemd/system/t8k-b2sync-daily.service
  rm -f /etc/systemd/system/t8k-b2sync-daily.timer
  rm -f /etc/systemd/system/t8k-b2sync-weekly.service
  rm -f /etc/systemd/system/t8k-b2sync-weekly.timer
  rm -f /etc/systemd/system/t8k-b2sync-monthly.service
  rm -f /etc/systemd/system/t8k-b2sync-monthly.timer
else
  systemctl stop t8k-b2sync-daily.timer
  systemctl disable t8k-b2sync-daily.timer
  rm -f /etc/systemd/system/t8k-b2sync-daily.service
  rm -f /etc/systemd/system/t8k-b2sync-daily.timer
fi

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

echo ""
echo Disable log rotation
rm /etc/logrotate.d/nginx."$NAME"

echo ""
echo Remove systemd path unit - build watch
systemctl stop t8k-"$NAME".path
systemctl disable t8k-"$NAME".path
rm /etc/systemd/system/t8k-"$NAME".path
rm /etc/systemd/system/t8k-"$NAME".service
