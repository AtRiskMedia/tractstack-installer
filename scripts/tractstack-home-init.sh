#!/bin/bash
TARGET=$2
if [[ -z "$TARGET" ]]; then
  cd ~/
  echo Tract Stack: home folder init: "$USER"

  mkdir tmp
  mkdir backup
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
  yes | COREPACK_ENABLE_STRICT=0 corepack prepare pnpm@9.12.3 --activate
  pnpm create astro@latest tractstack-storykeep \
    --template AtRiskMedia/tractstack-starter/template \
    --typescript strict \
    --install \
    --package-manager pnpm \
    --no-git \
    --skip-houston
  cd ~/src/
  echo Installing Code Base
  git clone https://github.com/AtRiskMedia/tractstack-starter.git
  cd ~/srv/
  echo Installing your Concierge
  git clone https://github.com/AtRiskMedia/tractstack-concierge.git
  cd tractstack-concierge
  composer install

elif [[ "$TARGET" == "features" || "$TARGET" == "sandbox" ]]; then
  NAME="$1"
  cd ~/"$TARGET"/"$NAME"
  echo Tract Stack: home folder init: "$NAME"

  mkdir tmp
  mkdir backup
  # Create initial empty MySQL backup file
  touch backup/mysql-backup.sql
  chown "$USER":www-data backup/mysql-backup.sql
  chmod 640 backup/mysql-backup.sql
  mkdir log
  mkdir watch
  mkdir src
  mkdir srv
  mkdir srv/public_html/
  cd srv/public_html

  echo Cloning repos.
  cd ~/"$TARGET"/"$NAME"/src
  echo Installing Tract Stack
  corepack enable
  yes | COREPACK_ENABLE_STRICT=0 corepack prepare pnpm@9.12.3 --activate
  pnpm create astro@latest tractstack-storykeep \
    --template AtRiskMedia/tractstack-starter/template \
    --typescript strict \
    --install \
    --package-manager pnpm \
    --no-git \
    --skip-houston
  echo done.
  cd ~/"$TARGET"/"$NAME"/src
  echo Installing Code Base
  git clone https://github.com/AtRiskMedia/tractstack-starter.git
  echo done.
  cd ~/"$TARGET"/"$NAME"/srv
  echo Installing your Concierge
  git clone https://github.com/AtRiskMedia/tractstack-concierge.git
  cd tractstack-concierge
  composer install
  echo done.
  echo ""
fi
