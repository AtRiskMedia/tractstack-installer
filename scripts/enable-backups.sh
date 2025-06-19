#!/bin/bash

ENHANCED_BACKUPS=true

NAME=$1

blue='\033[0;34m'
brightblue='\033[1;34m'
white='\033[1;37m'
reset='\033[0m'
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
echo -e "${white}  enabling backups for your tract stack"
echo -e "${reset}  by At Risk Media"
echo ""

if [ -z "$NAME" ]; then
  echo To enable backups provide linux user name
  echo Usage: sudo ./enable-backups.sh username
  echo ""
  exit 1
fi

if [ ! -d /home/"$NAME" ]; then
  echo User "$NAME" does not exist or Tract Stack not installed.
  echo ""
  exit 1
fi

if [ "$USER" != root ]; then
  echo Must provide sudo privileges
  echo ""
  exit 1
fi

echo "Enabling backups for Tract Stack user: $NAME"
echo ""

# B2 Backup Configuration
if [ ! -f /home/t8k/.env.b2 ]; then
  echo "Creating /home/t8k/.env.b2"
  read -p "Enter B2 bucket name: " B2_BUCKET_NAME
  read -p "Enter B2 application key ID: " B2_APPLICATION_KEY_ID
  read -p "Enter B2 application key: " B2_APPLICATION_KEY

  cat >/home/t8k/.env.b2 <<EOF
B2_BUCKET_NAME=${B2_BUCKET_NAME}
B2_APPLICATION_KEY_ID=${B2_APPLICATION_KEY_ID}
B2_APPLICATION_KEY=${B2_APPLICATION_KEY}
EOF
  chown t8k:t8k /home/t8k/.env.b2
  chmod 600 /home/t8k/.env.b2
fi

# Source B2 configuration to validate
source /home/t8k/.env.b2
if [ -z "$B2_BUCKET_NAME" ] || [ -z "$B2_APPLICATION_KEY_ID" ] || [ -z "$B2_APPLICATION_KEY" ]; then
  echo "ERROR: B2 configuration incomplete in /home/t8k/.env.b2"
  echo "Please ensure B2_BUCKET_NAME, B2_APPLICATION_KEY_ID, and B2_APPLICATION_KEY are set"
  exit 1
fi

# Configure rclone
mkdir -p /home/t8k/.config/rclone
cat >/home/t8k/.config/rclone/rclone.conf <<EOF
[tractstack-b2]
type = b2
account = ${B2_APPLICATION_KEY_ID}
key = ${B2_APPLICATION_KEY}
hard_delete = true
EOF
chown -R t8k:t8k /home/t8k/.config
chmod 700 /home/t8k/.config
chmod 600 /home/t8k/.config/rclone/rclone.conf

# Test the B2 configuration
echo "Testing B2 configuration..."
if ! RCLONE_CONFIG=/home/t8k/.config/rclone/rclone.conf rclone lsd tractstack-b2: >/dev/null 2>&1; then
  echo "ERROR: Failed to connect to B2. Please check your credentials."
  exit 1
fi
echo "B2 configuration successful!"

# Configure rsnapshot if not already done
if [ ! -f /etc/rsnapshot.conf ]; then
  if [ "$ENHANCED_BACKUPS" = true ]; then
    cp /home/t8k/tractstack-installer/files/rsnapshot/enhanced.conf /etc/rsnapshot.conf
  else
    cp /home/t8k/tractstack-installer/files/rsnapshot/growth.conf /etc/rsnapshot.conf
  fi
fi

# Copy B2 sync systemd services and timers
if [ "$ENHANCED_BACKUPS" = true ]; then
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-hourly.service /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-hourly.timer /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-daily.service /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-daily.timer /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-weekly.service /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-weekly.timer /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-monthly.service /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-monthly.timer /etc/systemd/system/
  systemctl enable t8k-b2sync-hourly.timer
  systemctl enable t8k-b2sync-daily.timer
  systemctl enable t8k-b2sync-weekly.timer
  systemctl enable t8k-b2sync-monthly.timer
  systemctl start t8k-b2sync-hourly.timer
  systemctl start t8k-b2sync-daily.timer
  systemctl start t8k-b2sync-weekly.timer
  systemctl start t8k-b2sync-monthly.timer
else
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-daily.service /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-b2sync-daily.timer /etc/systemd/system/
  systemctl enable t8k-b2sync-daily.timer
  systemctl start t8k-b2sync-daily.timer
fi

# Add backup paths for this instance (check if not already added)
if ! grep -q "backup.*$NAME/" /etc/rsnapshot.conf; then
  echo "Adding backup paths for user: $NAME"
  echo -e "backup\t/home/$NAME/.env\t$NAME/" >>/etc/rsnapshot.conf
  echo -e "backup\t/home/$NAME/src/tractstack-storykeep/.env\t$NAME/" >>/etc/rsnapshot.conf
  echo -e "backup\t/home/$NAME/src/tractstack-storykeep/src/custom/\t$NAME/" >>/etc/rsnapshot.conf
  echo -e "backup\t/home/$NAME/src/tractstack-storykeep/public/custom/\t$NAME/" >>/etc/rsnapshot.conf
  echo -e "backup\t/home/$NAME/src/tractstack-storykeep/public/images/\t$NAME/" >>/etc/rsnapshot.conf
else
  echo "Backup paths for user $NAME already exist in rsnapshot.conf"
fi

# Add to backup list if not already there
if [ ! -f /home/t8k/.env.backups ]; then
  touch /home/t8k/.env.backups
fi
if ! grep -q "^$NAME$" /home/t8k/.env.backups; then
  echo "$NAME" >>/home/t8k/.env.backups
fi

# Set up systemd timer if not exists
if [ ! -f /etc/systemd/system/t8k-backup.timer ]; then
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-backup.service /etc/systemd/system/
  cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-backup.timer /etc/systemd/system/

  if [ "$ENHANCED_BACKUPS" = true ]; then
    cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-backup-hourly.service /etc/systemd/system/
    cp /home/t8k/tractstack-installer/files/rsnapshot/systemd/t8k-backup-hourly.timer /etc/systemd/system/
    systemctl enable t8k-backup-hourly.timer
    systemctl start t8k-backup-hourly.timer
  fi

  systemctl enable t8k-backup.timer
  systemctl start t8k-backup.timer
fi

echo ""
echo "Backups have been successfully enabled for user: $NAME"
echo ""
if [ "$ENHANCED_BACKUPS" = true ]; then
  echo "Enhanced backup schedule:"
  echo "- Hourly snapshots (kept for 24 hours)"
  echo "- Daily snapshots (kept for 7 days)"
  echo "- Weekly snapshots (kept for 4 weeks)"
  echo "- Monthly snapshots (kept for 12 months)"
  echo "- B2 sync: hourly, daily, weekly, and monthly"
else
  echo "Standard backup schedule:"
  echo "- Daily snapshots"
  echo "- B2 sync: daily"
fi
echo ""
echo "Backup locations:"
echo "- /home/$NAME/.env"
echo "- /home/$NAME/src/tractstack-storykeep/.env"
echo "- /home/$NAME/src/tractstack-storykeep/src/custom/"
echo "- /home/$NAME/src/tractstack-storykeep/public/custom/"
echo "- /home/$NAME/src/tractstack-storykeep/public/images/"
echo ""
