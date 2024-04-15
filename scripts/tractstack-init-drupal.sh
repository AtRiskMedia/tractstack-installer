#!/bin/bash

TARGET=$4
if [[ -z "$TARGET" ]]; then
	NAME="$USER"
	DB_NAME=t8k_"$USER"
	SED_OAUTH='/^public_key\|^private_key/ s/tractstack/'"$NAME"'/g'
	cd ~/srv/public_html
else
	echo $3
	NAME=$3
	DB_NAME=t8k_"$NAME"
	SED_OAUTH='/^public_key\|^private_key/ s/tractstack/t8k\/'"$TARGET"'\/'"$3"'/g'
	echo ""
	echo "$SED_OAUTH"
	echo ""
	cd ~/"$TARGET"/"$NAME"/srv/public_html
fi

DB_PASSWORD=$1
ACCOUNT_PASSWORD=$2

echo Installing Drupal CMS
composer create-project drupal/recommended-project drupal
cd drupal
composer require --dev drush/drush
composer require 'drupal/jsonapi_extras:^3.24'
composer require 'drupal/simple_oauth:^5.2'

mkdir oauth_keys
cd oauth_keys
openssl genrsa -out private.key 2048
openssl rsa -in private.key -pubout >public.key
cd ..

cd web/profiles
git clone https://github.com/AtRiskMedia/tractstack-drupal.git
if [[ -z "$TARGET" ]]; then
	sed -i -e "$SED_OAUTH" /home/"$NAME"/srv/public_html/drupal/web/profiles/tractstack-drupal/config/install/simple_oauth.settings.yml
else
	echo sed -i -e "$SED_OAUTH" /home/t8k/"$TARGET"/"$NAME"/srv/public_html/drupal/web/profiles/tractstack-drupal/config/install/simple_oauth.settings.yml
	sed -i -e "$SED_OAUTH" /home/t8k/"$TARGET"/"$NAME"/srv/public_html/drupal/web/profiles/tractstack-drupal/config/install/simple_oauth.settings.yml
fi

cd ../..

./vendor/bin/drush site-install tractstack --db-url=mysql://"$DB_NAME":"$DB_PASSWORD"@localhost/"$DB_NAME" --site-name=TractStack-"$NAME" --account-name=admin --account-pass="$ACCOUNT_PASSWORD" -y
