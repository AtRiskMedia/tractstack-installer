#!/bin/bash

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
echo -e "${reset}All-in-one customer journey analytics web funnels builder"
echo -e "${white}by At Risk Media"
echo -e "${reset}"

TARGET=$(cat ~/releases/watch/build.lock)
echo $TARGET

if grep -q INITIALIZE_SHOPIFY=true ~/src/gatsby-starter-tractstack/.env.production; then
	SHOPIFY="1"
else
	SHOPIFY="0"
fi

if [ "$TARGET" = "back" ] || [ "$TARGET" = "all" ] || [ "$1" = "back" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building your ${white}Story Keep (backend)${reset}"
	cd ~/src/gatsby-starter-storykeep/
	git pull
	yarn install
	gatsby clean
	gatsby build
	cd ~/releases
	target=$(readlink -e ~/releases/storykeep/current)
	mkdir -p ~/releases/storykeep/"$NOW"
	cd ~/releases/storykeep/"$NOW"
	cp -rp ~/src/gatsby-starter-storykeep/public/* .
	ln -sf ~/srv/tractstack-concierge/api/
	ln -sf ~/srv/public_html/drupal/web/ d
	cd ~/releases/storykeep
	rm -rf $target
	ln -sf "$NOW" current
	cd ~/src/gatsby-starter-storykeep/
	echo -e "${blue}done.${reset}"
fi

if [ "$TARGET" = "front" ] || [ "$TARGET" = "all" ] || [ "$1" = "front" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building ${white}$SITENAME (frontend)${reset}"
	if [ "$SHOPIFY" -eq "1" ]; then
		cp -rp ~/src/gatsby-starter-tractstack/integrations/shopify/hooks/* ~/src/gatsby-starter-tractstack/src/hooks/
		cp -rp ~/src/gatsby-starter-tractstack/integrations/shopify/pages/* ~/src/gatsby-starter-tractstack/src/pages/
		cp -rp ~/src/gatsby-starter-tractstack/integrations/shopify/shopify-components ~/src/gatsby-starter-tractstack/src/
		cp ~/src/gatsby-starter-tractstack/integrations/shopify/gatsby-config.ts ~/src/gatsby-starter-tractstack/
	else
		cp ~/src/gatsby-starter-tractstack/integrations/no-shopify/gatsby-config.ts ~/src/gatsby-starter-tractstack/
		cp -rp ~/src/gatsby-starter-tractstack/integrations/no-shopify/shopify-components ~/src/gatsby-starter-tractstack/src/
		rm ~/src/gatsby-starter-tractstack/src/hooks/use-product-data.tsx
		rm ~/src/gatsby-starter-tractstack/src/pages/cart.tsx
		rm ~/src/gatsby-starter-tractstack/src/pages/products/{shopifyProduct.handle}.tsx
		rm ~/src/gatsby-starter-tractstack/src/shopify-components/AddToCart.tsx
		rm ~/src/gatsby-starter-tractstack/src/shopify-components/BuyNow.tsx
		rm ~/src/gatsby-starter-tractstack/src/shopify-components/LineItem.tsx
	fi
	cd ~/src/gatsby-starter-tractstack/
	git pull
	yarn install
	gatsby clean
	gatsby build
	cd ~/releases
	target=$(readlink -e ~/releases/tractstack/current)
	mkdir -p ~/releases/tractstack/"$NOW"
	cd ~/releases/tractstack/"$NOW"
	cp -rp ~/src/gatsby-starter-tractstack/public/* .
	ln -sf sitemap-index.xml sitemap.xml
	ln -sf ~/srv/tractstack-concierge/api/
	ln -sf ~/srv/public_html/drupal/web/ d
	cd ~/releases/tractstack
	rm -rf $target
	ln -sf "$NOW" current
	cd ~/src/gatsby-starter-tractstack/
	echo -e "${blue}done.${reset}"
fi

if [ "$RAN" = false ]; then
	echo Usage: ./build {target} where target = front, back, all or *key
else
	rm ~/releases/watch/build.lock 2>/dev/null || true
fi
