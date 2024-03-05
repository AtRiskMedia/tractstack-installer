#!/bin/bash

NAME=$1
SED='s/ZZZZZ/'"$NAME"'/g'
DRUPAL_OAUTH_CLIENT_SECRET=$(</dev/urandom tr -dc A-Za-z | head -c12)
SECRET_KEY=$(</dev/urandom tr -dc A-Za-z | head -c22)
BUILDER_SECRET_KEY=$(</dev/urandom tr -dc A-Za-z | head -c8)
DB_PASS=$(</dev/urandom tr -dc A-Za-z | head -c12)
DRUPAL_PASS=$(</dev/urandom tr -dc A-Za-z | head -c22)
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

if [ -d /home/"$NAME" ]; then
	echo User "$NAME" already exists.
	echo ""
	exit 1
fi

if [ "$NAME" = "" ]; then
	echo To install Tract Stack provide linux user name
	echo Usage: sudo ./tractstack-install.sh username
	echo ""
	exit 1
fi

if [ "$USER" != root ]; then
	echo Must provide sudo privileges
	echo ""
	exit 1
fi

echo ""
echo Creating Drupal database: t8k_"$NAME"
mysql -e "DROP DATABASE ${DB_NAME};" >/dev/null 2>&1
mysql -e "DROP USER ${DB_NAME}@localhost;" >/dev/null 2>&1
mysql -e "CREATE DATABASE ${DB_NAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;" >/dev/null 2>&1
mysql -e "CREATE USER ${DB_NAME}@localhost IDENTIFIED BY '${DB_PASS}';" >/dev/null 2>&1
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_NAME}'@'localhost';" >/dev/null 2>&1
mysql -e "FLUSH PRIVILEGES;" >/dev/null 2>&1

echo ""
echo Installing Tract Stack as user: "$NAME"
useradd -m "$NAME"
mkdir /home/"$NAME"/scripts
cp ./tractstack-home-init.sh /home/"$NAME"/scripts/
cp ./tractstack-init-drupal.sh /home/"$NAME"/scripts/
cp ./build.sh /home/"$NAME"/scripts/
sudo -H -u "$NAME" bash -c '~/scripts/tractstack-home-init.sh'
sudo -H -u "$NAME" bash -c '~/scripts/tractstack-init-drupal.sh '"$DB_PASS"' '"$DRUPAL_PASS"
cp ../files/drupal/web.config /home/"$NAME"/srv/public_html/drupal/oauth_keys
./fix-drupal.sh /home/"$NAME"/srv/public_html/drupal/web "$NAME"
chown "$NAME":www-data /home/"$NAME"/srv/public_html/drupal/oauth_keys
chown "$NAME":www-data /home/"$NAME"/srv/public_html/drupal/oauth_keys/*key
chown "$NAME":"$NAME" /home/"$NAME"/srv/public_html/drupal/oauth_keys/web.config
chmod 640 /home/"$NAME"/srv/public_html/drupal/oauth_keys/private.key
chmod 640 /home/"$NAME"/srv/public_html/drupal/oauth_keys/public.key
cat ../files/drupal/settings.incl >>/home/"$NAME"/srv/public_html/drupal/web/sites/default/settings.php
sed -i -e "$SED" /home/"$NAME"/srv/public_html/drupal/web/sites/default/settings.php

#echo ""
#echo Creating a certificate
#./cert.sh --expand -d "$NAME".tractstack.com -d storykeep."$NAME".tractstack.com

echo ""
echo Creating Concierge database: concierge_"$NAME"
mysql -e "DROP DATABASE ${CONCIERGE_DB_NAME};" >/dev/null 2>&1
mysql -e "CREATE DATABASE ${CONCIERGE_DB_NAME};" >/dev/null 2>&1
# uses t8k_"$NAME" as owner of database
mysql -e "GRANT ALL PRIVILEGES ON ${CONCIERGE_DB_NAME}.* TO '${DB_NAME}'@'localhost';" >/dev/null 2>&1
mysql -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
mysql "$CONCIERGE_DB_NAME" </home/"$NAME"/srv/tractstack-concierge/schema.sql

echo ""
echo Creating nginx config for "$NAME".tractstack.com and storykeep."$NAME".tractstack.com
cp ../files/nginx/storykeep.conf /etc/nginx/sites-available/storykeep."$NAME".conf
cp ../files/nginx/tractstack.conf /etc/nginx/sites-available/t8k."$NAME".conf
sed -i -e "$SED" /etc/nginx/sites-available/storykeep."$NAME".conf
sed -i -e "$SED" /etc/nginx/sites-available/t8k."$NAME".conf
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
cp ../files/conf/frontend.env.incl /home/"$NAME"/src/gatsby-starter-tractstack/.env.production
cp ../files/assets/* /home/"$NAME"/src/gatsby-starter-tractstack/assets/
truncate -s 0 /home/"$NAME"/src/gatsby-starter-tractstack/src/styles/custom.css
cp /home/"$NAME"/src/gatsby-starter-storykeep/src/custom/codehooks.tsx.example /home/"$NAME"/src/gatsby-starter-storykeep/src/custom/codehooks.tsx
cp ../files/conf/storykeep.env.incl /home/"$NAME"/src/gatsby-starter-storykeep/.env.production
cp ../files/assets/* /home/"$NAME"/src/gatsby-starter-storykeep/assets/
truncate -s 0 /home/"$NAME"/src/gatsby-starter-storykeep/src/styles/custom.css
cp /home/"$NAME"/src/gatsby-starter-tractstack/src/custom/codehooks.tsx.example /home/"$NAME"/src/gatsby-starter-tractstack/src/custom/codehooks.tsx
cp ../files/conf/concierge.env.incl /home/"$NAME"/srv/tractstack-concierge/.env
sed -i -e "$SED" /home/"$NAME"/src/gatsby-starter-tractstack/.env.production
sed -i -e "$SED" /home/"$NAME"/src/gatsby-starter-storykeep/.env.production
sed -i -e "$SED" /home/"$NAME"/srv/tractstack-concierge/.env
touch /home/"$NAME"/src/gatsby-starter-tractstack/tailwind.whitelist
chown "$NAME":www-data /home/"$NAME"/src/gatsby-starter-tractstack/tailwind.whitelist
chown "$NAME":www-data /home/"$NAME"/src/gatsby-starter-tractstack/.env.production
chown "$NAME":www-data /home/"$NAME"/src/gatsby-starter-storykeep/.env.production
chown "$NAME":www-data /home/"$NAME"/srv/tractstack-concierge/.env
chown "$NAME":www-data /home/"$NAME"/releases/watch
chmod 660 /home/"$NAME"/src/gatsby-starter-tractstack/tailwind.whitelist
chmod 660 /home/"$NAME"/src/gatsby-starter-tractstack/.env.production
chmod 660 /home/"$NAME"/src/gatsby-starter-storykeep/.env.production
chmod 660 /home/"$NAME"/srv/tractstack-concierge/.env
chmod 770 /home/"$NAME"/releases/watch

echo BASIC_AUTH_PASSWORD="$DRUPAL_PASS" >>/home/"$NAME"/src/gatsby-starter-tractstack/.env.production
echo BASIC_AUTH_PASSWORD="$DRUPAL_PASS" >>/home/"$NAME"/src/gatsby-starter-storykeep/.env.production
echo BUILDER_SECRET_KEY="$BUILDER_SECRET_KEY" >>/home/"$NAME"/src/gatsby-starter-storykeep/.env.production
echo DRUPAL_OAUTH_CLIENT_SECRET="$DRUPAL_OAUTH_CLIENT_SECRET" >>/home/"$NAME"/src/gatsby-starter-storykeep/.env.production
echo DB_PASSWORD="$DB_PASS" >>/home/"$NAME"/srv/tractstack-concierge/.env
echo SECRET_KEY="$SECRET_KEY" >>/home/"$NAME"/srv/tractstack-concierge/.env
echo BUILDER_SECRET_KEY="$BUILDER_SECRET_KEY" >>/home/"$NAME"/srv/tractstack-concierge/.env

echo ""
echo Running build on storykeep
sudo -H -u "$NAME" bash -c '~/scripts/build.sh back'
