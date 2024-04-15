#!/bin/bash
TARGET=$2
if [[ -z "$TARGET" ]]; then
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
	cd srv/public_html
	ln -s /home/"$USER"/releases/storykeep/current storykeep
	ln -s /home/"$USER"/releases/tractstack/current tractstack

	echo Cloning repos.
	cd ~/src/
	git clone https://github.com/AtRiskMedia/gatsby-starter-storykeep.git
	#git clone https://github.com/AtRiskMedia/gatsby-starter-tractstack.git
	git clone https://github.com/AtRiskMedia/tractstack-frontend.git
	cd ~/srv/
	git clone https://github.com/AtRiskMedia/tractstack-concierge.git
	echo Installing Concierge
	cd tractstack-concierge
	composer install

elif [[ "$TARGET" == "features" || "$TARGET" == "sandbox" ]]; then
	NAME="$1"
	cd ~/"$TARGET"/"$NAME"
	echo Tract Stack: home folder init: "$NAME"

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
	cd srv/public_html
	ln -s /home/t8k/"$TARGET"/"$NAME"/releases/storykeep/current storykeep
	ln -s /home/t8k/"$TARGET"/"$NAME"/releases/tractstack/current tractstack

	echo Cloning repos.
	cd ~/"$TARGET"/"$NAME"/src
	git clone https://github.com/AtRiskMedia/gatsby-starter-storykeep.git
	#git clone https://github.com/AtRiskMedia/gatsby-starter-tractstack.git
	git clone https://github.com/AtRiskMedia/tractstack-frontend.git
	cd ~/"$TARGET"/"$NAME"/srv
	git clone https://github.com/AtRiskMedia/tractstack-concierge.git
	echo Installing Concierge
	cd tractstack-concierge
	composer install
fi
