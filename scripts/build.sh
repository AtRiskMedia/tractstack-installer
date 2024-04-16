#!/bin/bash

if [ -f ../.env ]; then
	NAME_RAW=$(cat ../.env | grep NAME)
	NAME=$(echo "$NAME_RAW" | sed 's/NAME\=//g')
	USR_RAW=$(cat ../.env | grep USER)
	USR=$(echo "$USR_RAW" | sed 's/USER\=//g')
else
	echo "FATAL ERROR: Tract Stack ~/.env with NAME and USER not found."
	exit
fi

if [[ "$3" == "features" || "$3" == "sandbox" ]]; then
	OVERRIDE="$3"/"$3"_"$2"'/'
else
	OVERRIDE=
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

#if grep -q INITIALIZE_SHOPIFY=true /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/.env.production; then
#	SHOPIFY="1"
#else
#	SHOPIFY="0"
#fi

if [ "$TARGET" = "back" ] || [ "$TARGET" = "all" ] || [ "$1" = "back" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building your ${white}Story Keep (backend)${reset}"

	if [ "$USER" != "$USR" ]; then
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/ && git pull'
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/ && echo Y | yarn install'
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/ && gatsby clean; gatsby build'
		target=$(readlink -e /home/"$USR"/"$OVERRIDE"releases/storykeep/current)
		sudo -H -u "$USR" bash -c 'mkdir -p /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' '
		sudo -H -u "$USR" bash -c 'cp -rp /home/'"$USR"'/'"$OVERRIDE"'src/gatsby-starter-storykeep/public/* /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' '
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' && ln -sf /home/'"$USR"'/'"$OVERRIDE"'srv/tractstack-concierge/api/'
		sudo -H -u "$USR" bash -c 'cd /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' && ln -sf /home/'"$USR"'/'"$OVERRIDE"'srv/public_html/drupal/web/ d'
		sudo -H -u "$USR" bash -c 'ln -sf /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/'"$NOW"' /home/'"$USR"'/'"$OVERRIDE"'releases/storykeep/current'
		rm -rf $target

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
		ln -sf /home/"$USR"/"$OVERRIDE"srv/tractstack-concierge/api/
		ln -sf /home/"$USR"/"$OVERRIDE"srv/public_html/drupal/web/ d
		cd /home/"$USR"/"$OVERRIDE"releases/storykeep
		rm -rf $target
		ln -sf "$NOW" current
		cd /home/"$USR"/"$OVERRIDE"src/gatsby-starter-storykeep/
	fi
	echo -e "${blue}done.${reset}"
fi

if [ "$TARGET" = "front" ] || [ "$TARGET" = "all" ] || [ "$1" = "front" ] || [ "$1" = "all" ]; then
	echo ""
	echo REPLACED gatsby-starter-tractstack with tractstack-frontend but have not updated this script!
	RAN=true
	#echo ""
	#echo -e "building ${white}$SITENAME (frontend)${reset}"
	#if [ "$SHOPIFY" -eq "1" ]; then
	#	cp -rp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/hooks/* /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/hooks/
	#	cp -rp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/pages/* /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/pages/
	#	cp -rp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/shopify-components /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/
	#	cp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/gatsby-config.ts /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/
	#else
	#	cp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/no-shopify/gatsby-config.ts /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/
	#	cp -rp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/no-shopify/shopify-components /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/
	#	rm /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/hooks/use-product-data.tsx
	#	rm /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/pages/cart.tsx
	#	rm /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/pages/products/{shopifyProduct.handle}.tsx
	#	rm /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/shopify-components/AddToCart.tsx
	#	rm /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/shopify-components/BuyNow.tsx
	#	rm /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/src/shopify-components/LineItem.tsx
	#fi
	#cd /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/
	#git pull
	#yarn install
	#gatsby clean
	#y | gatsby build
	#cd /home/"$USR"/"$OVERRIDE"releases
	#target=$(readlink -e /home/"$USR"/"$OVERRIDE"releases/tractstack/current)
	#mkdir -p /home/"$USR"/"$OVERRIDE"releases/tractstack/"$NOW"
	#cd ~"$OVERRIDE"/releases/tractstack/"$NOW"
	#cp -rp /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/public/* .
	#ln -sf sitemap-index.xml sitemap.xml
	#ln -sf /home/"$USR"/"$OVERRIDE"srv/tractstack-concierge/api/
	#ln -sf /home/"$USR"/"$OVERRIDE"srv/public_html/drupal/web/ d
	#cd /home/"$USR"/"$OVERRIDE"releases/tractstack
	#rm -rf $target
	#ln -sf "$NOW" current
	#cd /home/"$USR"/"$OVERRIDE"src/gatsby-starter-tractstack/
	echo -e "${blue}done.${reset}"
fi

if [ "$RAN" = false ]; then
	echo Usage: ./build {target} where target = front, back, all or *key
else
	rm /home/"$USR"/"$OVERRIDE"releases/watch/build.lock 2>/dev/null || true
fi
