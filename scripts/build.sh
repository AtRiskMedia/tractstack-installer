#!/bin/bash

SITENAME="tractstack"
USER="tractstack"
WWW_TRACTSTACK="tractstack"
WWW_STORYKEEP="storykeep"
NOW=$(date +%s)
MORE=("atriskmedia-dot-com")
RAN=false

blue='\033[0;34m'
brightblue='\033[1;34m'
white='\033[1;37m'
reset='\033[0m'

echo -e "${brightblue}"
echo -e "${brightblue}  _                ${blue}  _       _             _     "
echo -e "${brightblue} | |_ _ __ __ _  ___| |_ ${blue}___| |_ __ _  ___| | __ "
echo -e "${brightblue} | __| \__/ _\` |/ __| __/ ${blue}__| __/ _\` |/ __| |/ / "
echo -e "${brightblue} | |_| | | (_| | (__| |_\__ ${blue}\ || (_| | (__|   <  "
echo -e "${brightblue}  \__|_|  \__,_|\___|\__|${blue}___/\__\__,_|\___|_|\_\ "
echo -e ""
echo -e "${reset}All-in-one customer journey analytics web funnels builder"
echo -e "${white}by At Risk Media"
echo -e "${reset}"

TARGET=$(cat /home/${USER}/releases/watch/build.lock)
echo $TARGET

if [ "$TARGET" = "back" ] || [ "$TARGET" = "all" ] || [ "$1" = "back" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building your ${white}Story Keep (backend)${reset}"
	cd /home/"$USER"/src/gatsby-starter-storykeep/
	git pull
	yarn install
	gatsby clean
	gatsby build
	cd /home/"$USER"/releases
	target=$(readlink -e /home/$USER/releases/storykeep/current)
	mkdir -p /home/"$USER"/releases/storykeep/"$NOW"
	cd /home/"$USER"/releases/storykeep/"$NOW"
	cp -rp /home/"$USER"/src/gatsby-starter-storykeep/public/* .
	ln -sf /home/"$USER"/srv/tractstack-concierge/api/
	ln -sf /home/"$USER"/srv/public_html/drupal/web/ d
	cd /home/"$USER"/releases/storykeep
	rm -rf $target
	ln -sf "$NOW" current
	cd /home/"$USER"/src/gatsby-starter-storykeep/
	echo -e "${blue}done.${reset}"
fi

if [ "$TARGET" = "front" ] || [ "$TARGET" = "all" ] || [ "$1" = "front" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building ${white}$SITENAME (frontend)${reset}"
	cd /home/"$USER"/src/gatsby-starter-tractstack/
	git pull
	yarn install
	gatsby clean
	gatsby build
	cd /home/"$USER"/releases
	target=$(readlink -e /home/$USER/releases/tractstack/current)
	mkdir -p /home/"$USER"/releases/tractstack/"$NOW"
	cd /home/"$USER"/releases/tractstack/"$NOW"
	cp -rp /home/"$USER"/src/gatsby-starter-tractstack/public/* .
	ln -sf /home/"$USER"/srv/tractstack-concierge/api/
	ln -sf /home/"$USER"/srv/public_html/drupal/web/ d
	cd /home/"$USER"/releases/tractstack
	rm -rf $target
	ln -sf "$NOW" current
	cd /home/"$USER"/src/gatsby-starter-tractstack/
	echo -e "${blue}done.${reset}"
fi

for value in "${MORE[@]}"; do
	if [ "$value" == "$TARGET" ] || [ "$TARGET" == "more" ] || [ "$value" == "$1" ] || [ "$1" == "more" ]; then
		RAN=true
		echo -e "building ${white}$value (special)${reset}"
		cd /home/"$USER"/src/"$value"/
		cp /home/"$USER"/src/gatsby-starter-tractstack/tailwind.whitelist .
		git pull
		yarn install
		gatsby clean
		gatsby build
		cd /home/"$USER"/releases
		target=$(readlink -e /home/$USER/releases/"$value"/current)
		mkdir -p /home/"$USER"/releases/"$value"/"$NOW"
		cd /home/"$USER"/releases/"$value"/"$NOW"
		cp -rp /home/"$USER"/src/"$value"/public/* .
		ln -sf /home/"$USER"/srv/tractstack-concierge/api/
		ln -sf /home/"$USER"/srv/public_html/drupal/web/ d
		cd /home/"$USER"/releases/"$value"
		rm -rf $target
		ln -sf "$NOW" current
		cd /home/"$USER"/src/"$value"/
		echo -e "${blue}done.${reset}"
	fi
done

if [ "$RAN" = false ]; then
	echo Usage: ./build {target} where target = front, back, all or *key
else
	rm /home/"$USER"/releases/watch/build.lock 2>/dev/null || true
fi
