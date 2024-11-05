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
  echo Installing Storykeep
  git clone https://github.com/AtRiskMedia/tractstack-storykeep.git
  cd tractstack-storykeep
  echo Using "api" branch pre-rc
  cd ~/srv/
  echo Installing Concierge
  git clone https://github.com/AtRiskMedia/tractstack-concierge.git
  cd tractstack-concierge
  composer install

elif [[ "$TARGET" == "features" || "$TARGET" == "sandbox" ]]; then
  NAME="$1"
  cd ~/"$TARGET"/"$NAME"
  echo Tract Stack: home folder init: "$NAME"

  mkdir tmp
  mkdir backup
  mkdir log
  mkdir watch
  mkdir src
  mkdir srv
  mkdir srv/public_html/
  cd srv/public_html

  echo Cloning repos.
  cd ~/"$TARGET"/"$NAME"/src
  echo Installing Storykeep
  git clone https://github.com/AtRiskMedia/tractstack-storykeep.git
  cd tractstack-storykeep
  echo Using "api" branch pre-rc
  echo done.
  echo ""
  cd ~/"$TARGET"/"$NAME"/srv
  echo Installing Concierge
  git clone https://github.com/AtRiskMedia/tractstack-concierge.git
  cd tractstack-concierge
  composer install
  echo done.
  echo ""
fi
