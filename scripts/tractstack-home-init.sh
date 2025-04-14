#!/bin/bash
cd ~/
echo Tract Stack: home folder init: "$USER"

mkdir tmp
mkdir log
mkdir watch
mkdir src
mkdir srv
mkdir srv/public_html/

cd srv/public_html
echo Cloning repos.
cd ~/src/
echo Installing Tract Stack
corepack enable
yes | COREPACK_ENABLE_STRICT=0 corepack prepare pnpm@9.15.4 --activate
pnpm create astro@latest tractstack-storykeep \
  --template AtRiskMedia/tractstack-starter/template \
  --typescript strict \
  --install \
  --package-manager pnpm \
  --no-git \
  --skip-houston
touch tractstack-storykeep/public/styles/frontend.css
echo {} >tractstack-storykeep/config/init.json
echo {} >tractstack-storykeep/config/turso.json
mkdir tractstack-storykeep/public/custom
mkdir tractstack-storykeep/tenants
cd ~/src/
echo Installing Code Base for easy updates
git clone https://github.com/AtRiskMedia/tractstack-starter.git
cd ~/srv/
echo Installing your Concierge
git clone https://github.com/AtRiskMedia/tractstack-concierge.git
cd tractstack-concierge
composer install
