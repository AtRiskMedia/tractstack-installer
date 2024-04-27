#!/bin/bash

if [[ "$1" == "tailwind" || "$1" == "front" || "$1" == "back" || "$1" == "all" || -z "$1" ]]; then
	echo Building "$1"
	echo ""
else
	echo Usage:
	echo sudo ./build.sh 1 2 3
	echo required: 1 = tailwind, front, back, all
	echo optional: 2 = username
	echo optional: 3 = features \| sandbox \(or blank\)
	echo ""
	exit
fi

if [ ! -z $3 ]; then
	echo cd /home/t8k/"$3"/"$3"_"$2"
	cd /home/t8k/"$3"/"$3"_"$2"
elif [ ! -z $2 ]; then
	echo cd /home/"$2"
	cd /home/"$2"
else
	echo cd ..
	cd ..
fi

if [ -f ./.env ]; then
	NAME_RAW=$(cat ./.env | grep NAME)
	NAME=$(echo "$NAME_RAW" | sed 's/NAME\=//g')
	USR_RAW=$(cat ./.env | grep USER)
	USR=$(echo "$USR_RAW" | sed 's/USER\=//g')
	PORT_RAW=$(cat ./.env | grep PORT)
	PORT=$(echo "$PORT_RAW" | sed 's/PORT\=//g')
else
	echo "FATAL ERROR: Tract Stack ~/.env with NAME and USER not found."
	exit
fi

if [[ "$3" == "features" || "$3" == "sandbox" ]]; then
	OVERRIDE="$3"/"$3"_"$2"'/'
	ID="$3"-"$2"
else
	OVERRIDE=
	ID="$USR"
fi

SITENAME="tractstack"
WWW_TRACTSTACK="tractstack"
WWW_STORYKEEP="storykeep"
NOW=$(date +%s)
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
echo -e "${reset}All-in-one publishing platform to grow your content into a business"
echo -e "${white}by At Risk Media"
echo -e "${reset}"

TARGET=$(cat /home/"$USR"/"$OVERRIDE"releases/watch/build.lock)

if [[ "$TARGET" = "tailwind" || "$1" = "tailwind" ]]; then
	RAN=true
fi
echo ""
echo -e "re-generating your ${white}styles${reset}"
cd /home/"$USR"/"$OVERRIDE"srv/tractstack-concierge/api/styles
if [ ! -s /home/"$USR"/"$OVERRIDE"srv/tractstack-concierge/api/styles/storykeep.css ]; then
	echo Generating css for storykeep
	cd storykeep
	cp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-storykeep/tailwind.whitelist .
	tailwindcss -m -o ../storykeep.css
	cd ..
fi
echo Generating css for frontend
cd frontend
tailwindcss -m -o ../frontend.css.new
cd ..
if cmp -s frontend.css frontend.css.new; then
	echo "* no changes"
else
	VER=$(cat v.json | tr -d " \t\n\r" | grep -o -E '[0-9]+')
	NEW_VER=$(("$VER" + 1))
	cp frontend.css.new frontend.css
	echo '{"v":'"$NEW_VER"'}' >v.json
	echo "new styles! incrementing version"
fi
rm frontend.css.new

if [ "$TARGET" = "back" ] || [ "$TARGET" = "all" ] || [ "$1" = "back" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building your ${white}Story Keep (backend)${reset}"

	if [ "$USER" != "$USR" ]; then
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/ && echo Y | yarn install'
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/ && gatsby clean; gatsby build'
		target=$(readlink -e /home/"$USR"/"$OVERRIDE"releases/storykeep/current)
		sudo -H -u "$USR" bash -c 'mkdir -p /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' '
		sudo -H -u "$USR" bash -c 'mv /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/public/* /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"'/ '
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' && ln -sfn /home/'"$USR"'/'"$OVERRIDE"'srv/tractstack-concierge/api/'
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' && ln -sfn /home/'"$USR"'/'"$OVERRIDE"'srv/public_html/drupal/web/ d'
		sudo -H -u "$USR" bash -c 'ln -sfn /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/current'
		if [ -f "$target" ]; then
			rm -rf $target
		fi

	else
		cd /home/"$USR"/"$OVERRIDE"src/gatsby-starter-storykeep/
		git pull
		echo Y | yarn install
		gatsby clean
		gatsby build
		cd /home/"$USR"/"$OVERRIDE"releases
		target=$(readlink -e /home/"$USR"/"$OVERRIDE"releases/storykeep/current)
		mkdir -p /home/"$USR"/"$OVERRIDE"releases/storykeep/"$NOW"
		cd /home/"$USR"/"$OVERRIDE"releases/storykeep/"$NOW"
		cp -rp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-storykeep/public/* .
		ln -sfn /home/"$USR"/"$OVERRIDE"srv/tractstack-concierge/api/
		ln -sfn /home/"$USR"/"$OVERRIDE"srv/public_html/drupal/web/ d
		cd /home/"$USR"/"$OVERRIDE"releases/storykeep
		ln -sfn "$NOW" current
		if [ -f "$target" ]; then
			rm -rf $target
		fi
		cd /home/"$USR"/"$OVERRIDE"src/gatsby-starter-storykeep/
	fi
	echo -e "${blue}done.${reset}"
fi

if [ "$TARGET" = "front" ] || [ "$TARGET" = "all" ] || [ "$1" = "front" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building ${white}$SITENAME (frontend)${reset}"

	if [ "$OVERRIDE" != "" ]; then
		cd /home/t8k/"$OVERRIDE"src/tractstack-frontend
	else
		cd /home/"$USR"/src/tractstack-frontend
	fi

	cd src
	SITE_URL_RAW=$(cat ../.env | grep PUBLIC_SITE_URL)
	SITE_URL=$(echo "$SITE_URL_RAW" | sed 's/PUBLIC_SITE_URL\=//g')
	sed -i "s@\(^\s*\)website:\s.*@\1website: \"https:\"\/\/$SITE_URL\\\",@" config.ts
	cd ..

	RUNNING=$(docker ps -q --filter ancestor=tractstack-frontend-"$ID")
	sudo docker build --network=host -t tractstack-frontend-"$ID" .
	if [ ! -z "$RUNNING" ]; then
		sudo docker stop "$RUNNING"
		sudo docker rm "$RUNNING"
		sudo docker ps
	else
		echo * new container
	fi
	sudo docker run --net=host -d --restart unless-stopped tractstack-frontend-"$ID"
	echo -e "${blue}done.${reset}"
fi

if [ "$RAN" = false ]; then
	echo Usage: ./build {target} where target = front, back, all or *key
else
	rm /home/"$USR"/"$OVERRIDE"releases/watch/build.lock 2>/dev/null || true
fi
