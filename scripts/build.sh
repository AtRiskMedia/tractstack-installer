#!/bin/bash

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

TARGET=$(cat ~/"$OVERRIDE"releases/watch/build.lock)
echo $TARGET

if grep -q INITIALIZE_SHOPIFY=true ~/"$OVERRIDE"src/gatsby-starter-tractstack/.env.production; then
	SHOPIFY="1"
else
	SHOPIFY="0"
fi

if [ "$TARGET" = "back" ] || [ "$TARGET" = "all" ] || [ "$1" = "back" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building your ${white}Story Keep (backend)${reset}"
	cd ~/"$OVERRIDE"src/gatsby-starter-storykeep/
	git pull
	yarn install
	gatsby clean
	y | gatsby build
	cd ~/"$OVERRIDE"releases
	target=$(readlink -e ~/"$OVERRIDE"releases/storykeep/current)
	mkdir -p ~/"$OVERRIDE"releases/storykeep/"$NOW"
	cd ~/"$OVERRIDE"releases/storykeep/"$NOW"
	cp -rp ~/"$OVERRIDE"src/gatsby-starter-storykeep/public/* .
	ln -sf ~/"$OVERRIDE"srv/tractstack-concierge/api/
	ln -sf ~/"$OVERRIDE"srv/public_html/drupal/web/ d
	cd ~/"$OVERRIDE"releases/storykeep
	rm -rf $target
	ln -sf "$NOW" current
	cd ~/"$OVERRIDE"src/gatsby-starter-storykeep/
	echo -e "${blue}done.${reset}"
fi

if [ "$TARGET" = "front" ] || [ "$TARGET" = "all" ] || [ "$1" = "front" ] || [ "$1" = "all" ]; then
	RAN=true
	echo ""
	echo -e "building ${white}$SITENAME (frontend)${reset}"
	if [ "$SHOPIFY" -eq "1" ]; then
		cp -rp ~/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/hooks/* ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/hooks/
		cp -rp ~/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/pages/* ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/pages/
		cp -rp ~/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/shopify-components ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/
		cp ~/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/shopify/gatsby-config.ts ~/"$OVERRIDE"src/gatsby-starter-tractstack/
	else
		cp ~/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/no-shopify/gatsby-config.ts ~/"$OVERRIDE"src/gatsby-starter-tractstack/
		cp -rp ~/"$OVERRIDE"src/gatsby-starter-tractstack/integrations/no-shopify/shopify-components ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/
		rm ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/hooks/use-product-data.tsx
		rm ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/pages/cart.tsx
		rm ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/pages/products/{shopifyProduct.handle}.tsx
		rm ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/shopify-components/AddToCart.tsx
		rm ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/shopify-components/BuyNow.tsx
		rm ~/"$OVERRIDE"src/gatsby-starter-tractstack/src/shopify-components/LineItem.tsx
	fi
	cd ~/"$OVERRIDE"src/gatsby-starter-tractstack/
	git pull
	yarn install
	gatsby clean
	y | gatsby build
	cd ~/"$OVERRIDE"releases
	target=$(readlink -e ~/"$OVERRIDE"releases/tractstack/current)
	mkdir -p ~/"$OVERRIDE"releases/tractstack/"$NOW"
	cd ~"$OVERRIDE"/releases/tractstack/"$NOW"
	cp -rp ~/"$OVERRIDE"src/gatsby-starter-tractstack/public/* .
	ln -sf sitemap-index.xml sitemap.xml
	ln -sf ~/"$OVERRIDE"srv/tractstack-concierge/api/
	ln -sf ~/"$OVERRIDE"srv/public_html/drupal/web/ d
	cd ~/"$OVERRIDE"releases/tractstack
	rm -rf $target
	ln -sf "$NOW" current
	cd ~/"$OVERRIDE"src/gatsby-starter-tractstack/
	echo -e "${blue}done.${reset}"
fi

if [ "$RAN" = false ]; then
	echo Usage: ./build {target} where target = front, back, all or *key
else
	rm ~/"$OVERRIDE"releases/watch/build.lock 2>/dev/null || true
fi
