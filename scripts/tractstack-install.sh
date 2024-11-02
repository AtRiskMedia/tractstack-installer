#!/bin/bash

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

TARGET=$2
SED_PORT='s/ZZZZY/'"$PORT"'/g'
if [[ -z "$TARGET" ]]; then
  NAME=$1
  INSTALL_USER=$1
  SED='s/ZZZZZ/'"$NAME"'/g'
elif [[ "$TARGET" == "features" || "$TARGET" == "sandbox" ]]; then
  NAME="$2"_"$1"
  INSTALL_USER="t8k"
  SED='s/ZZZZZ/'"$1"'/g'
  SED2='s/ZZZZZ/'"$NAME"'/g'
else
  echo To install Tract Stack with into a target environment, please specific features or sandbox
  echo Usage: sudo ./tractstack-install.sh username target
  echo ELSE for user install... Usage: sudo ./tractstack-install.sh username
  echo ""
  exit 1
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
echo -e "${reset}no-code website maker for advocacy and evanglism"
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

if [ -d /home/t8k/"$TARGET"/"$NAME" ]; then
  echo User "$NAME" already exists in "$TARGET".
  echo ""
  exit 1
fi

if [ "$USER" != root ]; then
  echo Must provide sudo privileges
  echo ""
  exit 1
fi

CONCIERGE_SECRET=$(</dev/urandom tr -dc A-Za-z | head -c8)
STORYKEEP_SECRET=$(</dev/urandom tr -dc A-Za-z | head -c8)
SECRET_KEY=$(</dev/urandom tr -dc A-Za-z | head -c22)
DB_PASS=$(</dev/urandom tr -dc A-Za-z | head -c12)
DB_NAME=t8k_"$NAME"
CONCIERGE_DB_NAME=concierge_"$NAME"

if [ "$NAME" == "$INSTALL_USER" ]; then
  if [ ! -f /etc/letsencrypt/live/"$NAME".tractstack.com ]; then
    echo ""
    echo Creating a certificate
    ./cert.sh --expand -d "$NAME".tractstack.com -d storykeep."$NAME".tractstack.com --dns-cloudflare-propagation-seconds 45
  fi
else
  if [ ! -f /etc/letsencrypt/live/"$TARGET"."$1".tractstack.com ]; then
    echo ""
    echo Creating a certificate
    ./cert.sh --expand -d "$TARGET"."$1".tractstack.com -d "$TARGET".storykeep."$1".tractstack.com --dns-cloudflare-propagation-seconds 45
  fi
fi

if [ "$NAME" == "$INSTALL_USER" ]; then
  echo ""
  echo Installing Tract Stack as user: "$NAME"
  useradd -m "$NAME"
  chown "$NAME":www-data /home/"$NAME"
  mkdir /home/"$NAME"/scripts
  cp ./tractstack-home-init.sh /home/"$NAME"/scripts/
  cp ./build.sh /home/"$NAME"/scripts/
  sudo -H -u "$NAME" bash -c '~/scripts/tractstack-home-init.sh'
  rm /home/"$NAME"/scripts/tractstack-home-init.sh
  mkdir /home/"$NAME"/srv/tractstack-concierge/api/images
  mkdir /home/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns
  cp ../files/images/paneDesigns/* /home/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns
  chown -R "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/api/images
  chmod 775 /home/"$NAME"/srv/tractstack-concierge/api/images
  chmod 775 /home/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns
  chmod 664 /home/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns/*
  mkdir /home/"$NAME"/srv/tractstack-concierge/api/styles
  mkdir /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend
  touch /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.whitelist
  touch /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend.css
  touch /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend.css.new
  touch /home/"$NAME"/srv/tractstack-concierge/api/styles/v.json
  cp ../files/tailwind/frontend.tailwind.config.cjs /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.config.cjs
  chown -R "$NAME":"$NAME" /home/"$NAME"/srv/tractstack-concierge/api/styles
  echo '{"v":0}' >/home/"$NAME"/srv/tractstack-concierge/api/styles/v.json
  chown -R "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.whitelist
  chmod 664 /home/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.whitelist
  mkdir /home/"$NAME"/srv/tractstack-concierge/api/aai
  chown "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/api/aai
  chmod 775 /home/"$NAME"/srv/tractstack-concierge/api/aai
  touch /home/"$NAME"/srv/tractstack-concierge/api/build.json
  chown "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/api/build.json
  echo '{"status":"none","lastBuild":0}' >/home/"$NAME"/srv/tractstack-concierge/api/build.json
  chmod 664 /home/"$NAME"/srv/tractstack-concierge/api/build.json
  mkdir -p /home/"$NAME"/srv/public_html/storykeep
  cd /home/"$NAME"/srv/public_html/storykeep
  ln -s ../../tractstack-concierge/api api
  cd - >/dev/null 2>&1
else
  echo ""
  echo Installing Tract Stack as target: "$TARGET" -- "$NAME"
  mkdir /home/t8k/"$TARGET"/"$NAME"
  mkdir /home/t8k/"$TARGET"/"$NAME"/scripts
  chown t8k:t8k /home/t8k/"$TARGET"/"$NAME"
  chown t8k:t8k /home/t8k/"$TARGET"/"$NAME"/scripts
  cp ./tractstack-home-init.sh /home/t8k/"$TARGET"/"$NAME"/scripts/
  cp ./build.sh /home/"t8k/"$TARGET"/$NAME"/scripts/
  sudo -H -u "$INSTALL_USER" bash -c '~/'"$TARGET"/"$NAME"'/scripts/tractstack-home-init.sh '"$NAME"' '"$TARGET"
  rm /home/t8k/"$TARGET"/"$NAME"/scripts/tractstack-home-init.sh
  mkdir /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/images
  mkdir /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/paneDesigns
  cp ../files/images/paneDesigns/* /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns
  chown -R "$NAME":www-data /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/images
  chmod 775 /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/images
  chmod 775 /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns
  chmod 664 /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/images/paneDesigns/*
  mkdir /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles
  mkdir /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend
  touch /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.whitelist
  touch /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend.css
  touch /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend.css.new
  touch /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/v.json
  cp ../files/tailwind/frontend.tailwind.config.cjs /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.config.cjs
  chown -R "$NAME":"$NAME" /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles
  echo '{"v":0}' >/home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/v.json
  chown -R t8k:www-data /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.whitelist
  chmod 664 /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/api/styles/frontend/tailwind.whitelist
  mkdir -p /home/t8k/"$TARGET"/"$NAME"/srv/public_html/storykeep
  cd /home/t8k/"$TARGET"/"$NAME"/srv/public_html/storykeep
  ln -s ../../tractstack-concierge/api api
  cd - >/dev/null 2>&1
fi

echo ""
echo Creating Concierge database: concierge_"$NAME"
mysql -e "CREATE USER ${DB_NAME}@localhost IDENTIFIED BY '${DB_PASS}';" >/dev/null 2>&1
mysql -e "DROP DATABASE ${CONCIERGE_DB_NAME};" >/dev/null 2>&1
mysql -e "CREATE DATABASE ${CONCIERGE_DB_NAME};" >/dev/null 2>&1
# uses t8k_"$NAME" as owner of database
mysql -e "GRANT ALL PRIVILEGES ON ${CONCIERGE_DB_NAME}.* TO '${DB_NAME}'@'localhost';" >/dev/null 2>&1
mysql -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
if [ "$NAME" == "$INSTALL_USER" ]; then
  mysql "$CONCIERGE_DB_NAME" </home/"$NAME"/srv/tractstack-concierge/schema.sql
else
  mysql "$CONCIERGE_DB_NAME" </home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/schema.sql
fi

if [ "$NAME" == "$INSTALL_USER" ]; then
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
else
  echo ""
  echo Creating nginx config for "$TARGET"."$1".tractstack.com and "$TARGET".storykeep."$1".tractstack.com
  cp ../files/nginx/"$TARGET".storykeep.conf /etc/nginx/sites-available/"$TARGET".storykeep."$1".conf
  cp ../files/nginx/"$TARGET".tractstack.conf /etc/nginx/sites-available/"$TARGET".t8k."$1".conf
  sed -i -e "$SED" /etc/nginx/sites-available/"$TARGET".storykeep."$1".conf
  sed -i -e "$SED" /etc/nginx/sites-available/"$TARGET".t8k."$1".conf
  sed -i -e "$SED_PORT" /etc/nginx/sites-available/"$TARGET".t8k."$1".conf
  cd /etc/nginx/sites-enabled
  ln -s ../sites-available/"$TARGET".storykeep."$1".conf
  ln -s ../sites-available/"$TARGET".t8k."$1".conf
  cd - >/dev/null 2>&1
  if ! nginx -t 2>/dev/null; then
    echo ""
    echo Fatal Error creating Nginx config!
    exit 1
    rm /etc/nginx/sites-available/"$TARGET".storykeep."$1".conf
    rm /etc/nginx/sites-available/"$TARGET".t8k."$1".conf
    rm /etc/nginx/sites-enabled/"$TARGET".storykeep."$1".conf
    rm /etc/nginx/sites-enabled/"$TARGET".t8k."$1".conf
    echo ""
    exit 1
  fi
fi
service nginx reload

echo ""
echo Enabling log rotation
truncate -s 0 /etc/logrotate.d/nginx."$NAME"
echo -n /home/"$NAME"/log/*.log" " >>/etc/logrotate.d/nginx."$NAME"
cat ../files/logrotate/nginx >>/etc/logrotate.d/nginx."$NAME"

echo ""
echo Add systemd path unit - build watch
if [ "$NAME" == "$INSTALL_USER" ]; then
  cp ../files/systemd/tractstack-tractstack.path /etc/systemd/system/t8k-"$NAME".path
  cp ../files/systemd/tractstack-tractstack.service /etc/systemd/system/t8k-"$NAME".service
else
  cp ../files/systemd/"$TARGET".tractstack-tractstack.path /etc/systemd/system/t8k-"$NAME".path
  cp ../files/systemd/"$TARGET".tractstack-tractstack.service /etc/systemd/system/t8k-"$NAME".service
fi
sed -i -e "$SED" /etc/systemd/system/t8k-"$NAME".path
sed -i -e "$SED" /etc/systemd/system/t8k-"$NAME".service
systemctl enable t8k-"$NAME".path
systemctl start t8k-"$NAME".path

if [ "$NAME" == "$INSTALL_USER" ]; then
  echo ""
  echo Deploying config
  echo NAME="$NAME" >/home/"$NAME"/.env
  echo USER="$NAME" >>/home/"$NAME"/.env
  echo PORT="$PORT" >>/home/"$NAME"/.env
  echo PORT_"$NAME"="$PORT" >>/home/t8k/.env
  cp ../files/conf/storykeep.env.incl /home/"$NAME"/src/tractstack-storykeep/.env
  cp ../files/tractstack-storykeep/Dockerfile /home/"$NAME"/src/tractstack-storykeep
  cp ../files/tractstack-storykeep/src/config.ts /home/"$NAME"/src/tractstack-storykeep/src/
  cp -r ../files/tractstack-storykeep/public /home/"$NAME"/src/tractstack-storykeep/
  cp -r ../files/tractstack-storykeep/src/custom /home/"$NAME"/src/tractstack-storykeep/src/
  cp ../files/conf/concierge.env.incl /home/"$NAME"/srv/tractstack-concierge/.env
  cp /home/"$NAME"/src/tractstack-storykeep/public/logo.png /home/"$NAME"/src/tractstack-storykeep/public/custom/og.png
  cp /home/"$NAME"/src/tractstack-storykeep/public/og.png /home/"$NAME"/src/tractstack-storykeep/public/custom/og.png
  sed -i -e "$SED" /home/"$NAME"/src/tractstack-storykeep/.env
  sed -i -e "$SED" /home/"$NAME"/src/tractstack-storykeep/Dockerfile
  sed -i -e "$SED_PORT" /home/"$NAME"/src/tractstack-storykeep/Dockerfile
  sed -i -e "$SED" /home/"$NAME"/src/tractstack-storykeep/src/config.ts
  sed -i -e "$SED" /home/"$NAME"/srv/tractstack-concierge/.env
  touch /home/"$NAME"/src/tractstack-storykeep/tailwind.whitelist
  chown "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/tailwind.whitelist
  chown "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/.env
  chown "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/Dockerfile
  chown "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/src/config.ts
  chown -R "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/src/custom
  chown -R "$NAME":www-data /home/"$NAME"/src/tractstack-storykeep/public
  chown "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/.env
  chown "$NAME":www-data /home/"$NAME"/watch
  chmod 660 /home/"$NAME"/src/tractstack-storykeep/.env
  chmod 770 /home/"$NAME"/src/tractstack-storykeep/public/styles
  chmod 660 /home/"$NAME"/src/tractstack-storykeep/public/styles/custom.css
  chmod 770 /home/"$NAME"/src/tractstack-storykeep/public/custom
  chmod 660 /home/"$NAME"/src/tractstack-storykeep/public/custom/logo.png
  chmod 660 /home/"$NAME"/src/tractstack-storykeep/public/custom/og.png
  chmod 660 /home/"$NAME"/srv/tractstack-concierge/.env
  chmod 770 /home/"$NAME"/watch

  echo DB_PASSWORD="$DB_PASS" >>/home/"$NAME"/srv/tractstack-concierge/.env
  echo SECRET_KEY="$SECRET_KEY" >>/home/"$NAME"/srv/tractstack-concierge/.env
  echo CONCIERGE_SECRET="$CONCIERGE_SECRET" >>/home/"$NAME"/srv/tractstack-concierge/.env
  echo PRIVATE_CONCIERGE_SECRET="$CONCIERGE_SECRET" >>/home/"$NAME"/src/tractstack-storykeep/.env
  echo PRIVATE_AUTH_SECRET="$STORYKEEP_SECRET" >>/home/"$NAME"/src/tractstack-storykeep/.env

  echo ""
  echo Running build
  cd /home/"$NAME"/scripts
  ./build.sh all

else
  echo ""
  echo Deploying config in "$TARGET"
  echo NAME="$NAME" >/home/t8k/"$TARGET"/"$NAME"/.env
  echo USER=t8k >>/home/t8k/"$TARGET"/"$NAME"/.env
  echo PORT="$PORT" >>/home/t8k/"$TARGET"/"$NAME"/.env
  echo PORT_"$NAME"="$PORT" >>/home/t8k/.env
  cp ../files/conf/"$TARGET".storykeep.env.incl /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/.env
  cp ../files/tractstack-storykeep/"$TARGET".Dockerfile /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/Dockerfile
  cp ../files/tractstack-storykeep/src/"$TARGET".config.ts /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/src/config.ts
  cp -r ../files/tractstack-storykeep/public /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/
  cp -r ../files/tractstack-storykeep/src/custom /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/src/
  cp ../files/conf/"$TARGET".concierge.env.incl /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/.env
  cp /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/logo.png /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/custom/logo.png
  cp /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/og.png /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/custom/og.png
  sed -i -e "$SED" /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/.env
  sed -i -e "$SED" /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/Dockerfile
  sed -i -e "$SED_PORT" /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/Dockerfile
  sed -i -e "$SED" /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/src/config.ts
  sed -i -e "$SED2" /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/.env
  chown t8k:www-data /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/.env
  chown t8k:www-data /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/Dockerfile
  chown t8k:www-data /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/src/config.ts
  chown -R t8k:www-data /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/src/custom
  chown -R t8k:www-data /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public
  chown t8k:www-data /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/.env
  chown t8k:www-data /home/t8k/"$TARGET"/"$NAME"/watch
  chmod 660 /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/.env
  chmod 770 /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/styles
  chmod 660 /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/styles/custom.css
  chmod 770 /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/custom
  chmod 660 /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/custom/og.png
  chmod 660 /home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/public/custom/logo.png
  chmod 660 /home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/.env
  chmod 770 /home/t8k/"$TARGET"/"$NAME"/watch

  echo DB_PASSWORD="$DB_PASS" >>/home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/.env
  echo SECRET_KEY="$SECRET_KEY" >>/home/t8k/"$TARGET"/"$NAME"/srv/tractstack-concierge/.env
  echo PRIVATE_CONCIERGE_SECRET="$CONCIERGE_SECRET" >>/home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/.env
  echo PRIVATE_AUTH_SECRET="$STORYKEEP_SECRET" >>/home/t8k/"$TARGET"/"$NAME"/src/tractstack-storykeep/.env

  echo ""
  echo Running build
  cd /home/t8k/"$TARGET"/"$NAME"/scripts
  ./build.sh all "$1" "$TARGET"
fi

echo ""
echo Congrats Tract Stack has been installed to:
if [ "$NAME" == "$INSTALL_USER" ]; then
  echo /home/"$NAME"/
else
  echo /home/t8k/"$TARGET"/"$NAME"/
fi

echo ""
echo - log-in to your storykeep:
if [ "$NAME" == "$INSTALL_USER" ]; then
  echo https://"$NAME".tractstack.com/storykeep/login?force=true
else
  echo https://"$TARGET".storykeep."$1".tractstack.com
  echo https://"TARGET"."$1".tractstack.com/storykeep/login?force=true
fi
echo your initial password is: "$STORYKEEP_SECRET"
echo ""
