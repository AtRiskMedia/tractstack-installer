#!/bin/bash

ENHANCED_BACKUPS=true
NAME=$1
INSTALL_USER=$1
ID="$1"

# Define paths as variables
ENV_FILE="/home/t8k/.env"
ENV_BACKUPS="/home/t8k/.env.backups"
BACKUP_DIR="/home/t8k/backup"
RSNAPSHOT_CONF="/etc/rsnapshot.conf"
NGINX_SITES_AVAIL="/etc/nginx/sites-available"
NGINX_SITES_ENAB="/etc/nginx/sites-enabled"
LOGROTATE_DIR="/etc/logrotate.d"
SYSTEMD_DIR="/etc/systemd/system"

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

if [ "$USER" != "root" ]; then
  echo Must provide sudo privileges
  echo ""
  exit 1
fi

RUNNING=$(docker ps -q --filter ancestor=tractstack-storykeep-"$ID")
if [ ! -z "$RUNNING" ]; then
  echo ""
  echo Stopping Docker
  docker stop "$RUNNING"
  docker rm "$RUNNING"
  echo "Waiting for resources to be released..."
  sleep 5
fi

echo ""
echo Cancelling port reservation
[ -f "$ENV_FILE" ] && cp "$ENV_FILE" "$ENV_FILE.bak" && grep -v "^PORT_""$NAME" "$ENV_FILE.bak" >"$ENV_FILE"

echo ""
echo Removing Tract Stack for user: "$NAME"
deluser "$NAME"
[ -d /home/"$NAME" ] && rm -rf /home/"$NAME"

echo ""
echo "Removing backup configuration"
[ -f "$ENV_BACKUPS" ] && sed -i "/^$NAME$/d" "$ENV_BACKUPS"
[ -d "$BACKUP_DIR/$NAME" ] && rm -rf "$BACKUP_DIR/$NAME"
[ -f "$RSNAPSHOT_CONF" ] && sed -i "/backup.*\/$NAME\//d" "$RSNAPSHOT_CONF"

if [ -f "$ENV_BACKUPS" ] && [ ! -s "$ENV_BACKUPS" ]; then
  systemctl is-active t8k-backup.timer >/dev/null 2>&1 && systemctl stop t8k-backup.timer
  systemctl is-enabled t8k-backup.timer >/dev/null 2>&1 && systemctl disable t8k-backup.timer
  [ -f "$SYSTEMD_DIR/t8k-backup.timer" ] || [ -f "$SYSTEMD_DIR/t8k-backup.service" ] && rm -f "$SYSTEMD_DIR/t8k-backup"*
  systemctl is-active t8k-mysql-backup.timer >/dev/null 2>&1 && systemctl stop t8k-mysql-backup.timer
  systemctl is-enabled t8k-mysql-backup.timer >/dev/null 2>&1 && systemctl disable t8k-mysql-backup.timer
  systemctl is-active t8k-mysql-backup-weekly.timer >/dev/null 2>&1 && systemctl stop t8k-mysql-backup-weekly.timer
  systemctl is-enabled t8k-mysql-backup-weekly.timer >/dev/null 2>&1 && systemctl disable t8k-mysql-backup-weekly.timer
  [ -f "$SYSTEMD_DIR/t8k-mysql-backup.timer" ] || [ -f "$SYSTEMD_DIR/t8k-mysql-backup-weekly.timer" ] && rm -f "$SYSTEMD_DIR/t8k-mysql-backup"*
  [ -f "$RSNAPSHOT_CONF" ] && rm -f "$RSNAPSHOT_CONF"
fi

echo ""
echo "Removing B2 sync systemd units"
if [ "$ENHANCED_BACKUPS" = true ]; then
  systemctl is-active t8k-b2sync-hourly.timer >/dev/null 2>&1 && systemctl stop t8k-b2sync-hourly.timer
  systemctl is-enabled t8k-b2sync-hourly.timer >/dev/null 2>&1 && systemctl disable t8k-b2sync-hourly.timer
  systemctl is-active t8k-b2sync-daily.timer >/dev/null 2>&1 && systemctl stop t8k-b2sync-daily.timer
  systemctl is-enabled t8k-b2sync-daily.timer >/dev/null 2>&1 && systemctl disable t8k-b2sync-daily.timer
  systemctl is-active t8k-b2sync-weekly.timer >/dev/null 2>&1 && systemctl stop t8k-b2sync-weekly.timer
  systemctl is-enabled t8k-b2sync-weekly.timer >/dev/null 2>&1 && systemctl disable t8k-b2sync-weekly.timer
  systemctl is-active t8k-b2sync-monthly.timer >/dev/null 2>&1 && systemctl stop t8k-b2sync-monthly.timer
  systemctl is-enabled t8k-b2sync-monthly.timer >/dev/null 2>&1 && systemctl disable t8k-b2sync-monthly.timer
  [ -f "$SYSTEMD_DIR/t8k-b2sync-hourly.service" ] || [ -f "$SYSTEMD_DIR/t8k-b2sync-hourly.timer" ] && rm -f "$SYSTEMD_DIR/t8k-b2sync-hourly"*
  [ -f "$SYSTEMD_DIR/t8k-b2sync-daily.service" ] || [ -f "$SYSTEMD_DIR/t8k-b2sync-daily.timer" ] && rm -f "$SYSTEMD_DIR/t8k-b2sync-daily"*
  [ -f "$SYSTEMD_DIR/t8k-b2sync-weekly.service" ] || [ -f "$SYSTEMD_DIR/t8k-b2sync-weekly.timer" ] && rm -f "$SYSTEMD_DIR/t8k-b2sync-weekly"*
  [ -f "$SYSTEMD_DIR/t8k-b2sync-monthly.service" ] || [ -f "$SYSTEMD_DIR/t8k-b2sync-monthly.timer" ] && rm -f "$SYSTEMD_DIR/t8k-b2sync-monthly"*
else
  systemctl is-active t8k-b2sync-daily.timer >/dev/null 2>&1 && systemctl stop t8k-b2sync-daily.timer
  systemctl is-enabled t8k-b2sync-daily.timer >/dev/null 2>&1 && systemctl disable t8k-b2sync-daily.timer
  [ -f "$SYSTEMD_DIR/t8k-b2sync-daily.service" ] || [ -f "$SYSTEMD_DIR/t8k-b2sync-daily.timer" ] && rm -f "$SYSTEMD_DIR/t8k-b2sync-daily"*
fi

echo ""
echo Removing nginx config for "$NAME".tractstack.com and storykeep."$NAME".tractstack.com
[ -f "$NGINX_SITES_AVAIL/storykeep.$NAME.conf" ] && rm "$NGINX_SITES_AVAIL/storykeep.$NAME.conf"
[ -f "$NGINX_SITES_AVAIL/t8k.$NAME.conf" ] && rm "$NGINX_SITES_AVAIL/t8k.$NAME.conf"
[ -L "$NGINX_SITES_ENAB/storykeep.$NAME.conf" ] && rm "$NGINX_SITES_ENAB/storykeep.$NAME.conf"
[ -L "$NGINX_SITES_ENAB/t8k.$NAME.conf" ] && rm "$NGINX_SITES_ENAB/t8k.$NAME.conf"
nginx -t 2>/dev/null || {
  echo "Fatal Error removing Nginx config! UNSAFE CONFIG!!!"
  exit 1
}
systemctl reload nginx

echo ""
echo Disable log rotation
[ -f "$LOGROTATE_DIR/nginx.$NAME" ] && rm "$LOGROTATE_DIR/nginx.$NAME"

echo ""
echo Remove systemd path unit - build watch
systemctl is-active t8k-"$NAME".path >/dev/null 2>&1 && systemctl stop t8k-"$NAME".path
systemctl is-enabled t8k-"$NAME".path >/dev/null 2>&1 && systemctl disable t8k-"$NAME".path
[ -f "$SYSTEMD_DIR/t8k-$NAME.path" ] && rm "$SYSTEMD_DIR/t8k-$NAME.path"
[ -f "$SYSTEMD_DIR/t8k-$NAME.service" ] && rm "$SYSTEMD_DIR/t8k-$NAME.service"
