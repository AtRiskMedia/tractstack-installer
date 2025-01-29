#!/bin/bash

ENHANCED_BACKUPS=true

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

if [ -f /home/t8k/.env ]; then
  array=(4321 4322 4323 4324 4325 4326 4327 4328 4329 4330 4331 4332 4333 4334 4335 4336 4337 4338 4339 4340 4341 4342 4343 4344 4345 4346 4347 4348 4349 4350 4351)
  for i in "${array[@]}"; do
    USED=$(cat /home/t8k/.env | grep "$i" | wc -l)
    if [ -z "$PORT" ]; then
      if [ "$USED" == 0 ]; then
        echo !! using port $i
        PORT=$i
      fi
    fi
  done
else
  PORT=4321
fi
if [ -z "$PORT" ]; then
  echo FATAL ERROR: All ports are allocated.
  exit
fi

SED_PORT='s/ZZZZY/'"$PORT"'/g'
NAME=$1
INSTALL_USER=$1
SED='s/ZZZZZ/'"$NAME"'/g'

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
echo -e "${reset}free web press"
echo -e "${white}by At Risk Media"
echo -e "${reset}"

if [ -z "$NAME" ]; then
  echo To install Tract Stack provide linux user name
  echo Usage: sudo ./tractstack-install.sh username
  echo ""
  exit 1
fi

if [ -d /home/"$NAME" ]; then
  echo User "$NAME" already exists.
  echo ""
  exit 1
fi

if [ "$USER" != root ]; then
  echo Must provide sudo privileges
  echo ""
  exit 1
fi

CONCIERGE_SECRET=$(</dev/urandom tr -dc A-Za-z | head -c8)
CONCIERGE_PUBLIC_SECRET=$(</dev/urandom tr -dc A-Za-z | head -c8)
STORYKEEP_SECRET=$(</dev/urandom tr -dc A-Za-z | head -c8)
SECRET_KEY=$(</dev/urandom tr -dc A-Za-z | head -c22)

if [ ! -f /etc/letsencrypt/live/"$NAME".tractstack.com ]; then
  echo ""
  echo Creating a certificate
  ./cert.sh --expand -d "$NAME".tractstack.com -d storykeep."$NAME".tractstack.com --dns-cloudflare-propagation-seconds 45
fi

echo "$NAME" >>/home/t8k/.env.backups
echo ""
echo Installing Tract Stack as user: "$NAME"
useradd -m "$NAME"
chown "$NAME":www-data /home/"$NAME"
mkdir /home/"$NAME"/scripts
cp ./tractstack-home-init.sh /home/"$NAME"/scripts/
cp ./build.sh /home/"$NAME"/scripts/
sudo -H -u "$NAME" bash -c '~/scripts/tractstack-home-init.sh'
rm /home/"$NAME"/scripts/tractstack-home-init.sh
touch /home/"$NAME"/srv/tractstack-concierge/api/build.json
chown "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/api/build.json
echo '{"status":"none","lastBuild":0}' >/home/"$NAME"/srv/tractstack-concierge/api/build.json
chmod 664 /home/"$NAME"/srv/tractstack-concierge/api/build.json
mkdir -p /home/"$NAME"/srv/public_html/storykeep
cd /home/"$NAME"/srv/public_html/storykeep
ln -s ../../tractstack-concierge/api api

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

# Add backup paths for this instance
echo -e "backup\t/home/$NAME/.env\t$NAME/" >>/etc/rsnapshot.conf
echo -e "backup\t/home/$NAME/src/tractstack-storykeep/.env\t$NAME/" >>/etc/rsnapshot.conf
echo -e "backup\t/home/$NAME/src/tractstack-storykeep/src/custom/\t$NAME/" >>/etc/rsnapshot.conf
echo -e "backup\t/home/$NAME/src/tractstack-storykeep/public/custom/\t$NAME/" >>/etc/rsnapshot.conf

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

cd - >/dev/null 2>&1

echo ""
echo Creating nginx config for "$NAME".tractstack.com and storykeep."$NAME".tractstack.com
cp ../files/nginx/storykeep.conf /etc/nginx/sites-available/storykeep."$NAME".conf
cp ../files/nginx/tractstack.conf /etc/nginx/sites-available/t8k."$NAME".conf
sed -i -e "$SED" /etc/nginx/sites-available/storykeep."$NAME".conf
sed -i -e "$SED" /etc/nginx/sites-available/t8k."$NAME".conf
sed -i -e "$SED_PORT" /etc/nginx/sites-available/t8k."$NAME".conf
cd /etc/nginx/sites-enabled
ln -s ../sites-available/storykeep."$NAME".conf
ln -s ../sites-available/t8k."$NAME".conf
cd - >/dev/null 2>&1
if ! nginx -t 2>/dev/null; then
  echo ""
  echo Fatal Error creating Nginx config!
  rm /etc/nginx/sites-available/storykeep."$NAME".conf
  rm /etc/nginx/sites-available/t8k."$NAME".conf
  rm /etc/nginx/sites-enabled/storykeep."$NAME".conf
  rm /etc/nginx/sites-enabled/t8k."$NAME".conf
  echo ""
  exit 1
fi
service nginx reload

echo ""
echo Enabling log rotation
truncate -s 0 /etc/logrotate.d/nginx."$NAME"
echo -n /home/"$NAME"/log/*.log" " >>/etc/logrotate.d/nginx."$NAME"
cat ../files/logrotate/nginx >>/etc/logrotate.d/nginx."$NAME"

echo ""
echo Add systemd path unit - build watch
cp ../files/systemd/tractstack-tractstack.path /etc/systemd/system/t8k-"$NAME".path
cp ../files/systemd/tractstack-tractstack.service /etc/systemd/system/t8k-"$NAME".service
sed -i -e "$SED" /etc/systemd/system/t8k-"$NAME".path
sed -i -e "$SED" /etc/systemd/system/t8k-"$NAME".service
systemctl enable t8k-"$NAME".path
systemctl start t8k-"$NAME".path

echo ""
echo Deploying config
echo NAME="$NAME" >/home/"$NAME"/.env
echo USER="$NAME" >>/home/"$NAME"/.env
echo PORT="$PORT" >>/home/"$NAME"/.env
echo PORT_"$NAME"="$PORT" >>/home/t8k/.env
cp ../files/conf/concierge.env.incl /home/"$NAME"/srv/tractstack-concierge/.env
cp ../files/conf/storykeep.env.incl /home/"$NAME"/src/tractstack-storykeep/.env
cp ../files/tractstack-storykeep/Dockerfile /home/"$NAME"/src/tractstack-storykeep
sed -i -e "$SED" /home/"$NAME"/srv/tractstack-concierge/.env
sed -i -e "$SED" /home/"$NAME"/src/tractstack-storykeep/.env
sed -i -e "$SED" /home/"$NAME"/src/tractstack-storykeep/Dockerfile
sed -i -e "$SED_PORT" /home/"$NAME"/src/tractstack-storykeep/Dockerfile
chown "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/.env
chown "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/Dockerfile
chown "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/.env
chown "$NAME":www-data /home/"$NAME"/watch
chmod 660 /home/"$NAME"/srv/tractstack-concierge/.env
chmod 660 /home/"$NAME"/src/tractstack-storykeep/.env
chmod 770 /home/"$NAME"/watch

echo SECRET_KEY="$SECRET_KEY" >>/home/"$NAME"/srv/tractstack-concierge/.env
echo CONCIERGE_SECRET="$CONCIERGE_SECRET" >>/home/"$NAME"/srv/tractstack-concierge/.env
echo PRIVATE_CONCIERGE_AUTH_SECRET="$CONCIERGE_SECRET" >>/home/"$NAME"/src/tractstack-storykeep/.env
echo PUBLIC_CONCIERGE_AUTH_SECRET="$CONCIERGE_PUBLIC_SECRET" >>/home/"$NAME"/src/tractstack-storykeep/.env
echo PRIVATE_ADMIN_PASSWORD="$STORYKEEP_SECRET" >>/home/"$NAME"/src/tractstack-storykeep/.env
echo PRIVATE_EDITOR_PASSWORD="$STORYKEEP_SECRET" >>/home/"$NAME"/src/tractstack-storykeep/.env

echo ""
echo Running build
cd /home/"$NAME"/scripts
./build.sh all

echo ""
echo Congrats Tract Stack has been installed to:
echo /home/"$NAME"/

echo ""
echo - log-in to your storykeep:
echo https://"$NAME".tractstack.com/storykeep/login?force=true

echo your initial password is: "$STORYKEEP_SECRET"
echo ""
