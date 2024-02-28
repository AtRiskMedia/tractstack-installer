#!/bin/bash

cd ~/
echo Tract Stack: home folder init: "$USER"

mkdir tmp
mkdir backup
mkdir log
mkdir releases
mkdir releases/storykeep
mkdir releases/tractstack
mkdir releases/watch
mkdir src
mkdir srv
mkdir srv/public_html/

echo Cloning repos.
cd ~/src/
git clone https://github.com/AtRiskMedia/gatsby-starter-storykeep.git
git clone https://github.com/AtRiskMedia/gatsby-starter-tractstack.git
cd ~/srv/public_html
git clone https://github.com/AtRiskMedia/tractstack-concierge.git
