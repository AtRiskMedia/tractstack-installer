#!/bin/bash

NAME="$USER"
DB_NAME="$USER"
DB_USER=demo
DB_PASSWORD=demo
ACCOUNT_PASSWORD=demo

echo Installing Drupal CMS
cd ~/srv/public_html
composer create-project drupal/recommended-project drupal
cd drupal
composer require --dev drush/drush
read -rsp $'Press any key to continue...\n' -n1 key
composer require 'drupal/jsonapi_extras:^3.24'
composer require 'drupal/simple_oauth:^5.2'
read -rsp $'Press any key to continue...\n' -n1 key

mkdir oauth_keys
cd oauth_keys
openssl genrsa -out private.key 2048
openssl rsa -in private.key -pubout >public.key
cd ..

cd web/profiles
git clone https://github.com/AtRiskMedia/tractstack-drupal.git
cd ../..

./vendor/bin/drush site-install tractstack --db-url=mysql://"$DB_USER":"$DB_PASSWORD"@localhost/"$DB_NAME" --site-name=TractStack-"$NAME" --account-name=admin --account-pass="$ACCOUNT_PASSWORD" -y
