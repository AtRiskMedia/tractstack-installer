#!/bin/bash

path=${1%/}
user=${2}
#group=${2}
group=www-data

help="\nHelp: This script is used to fix permissions of a Drupal 8 installation in which the PHP Handler is FastCGI\nYou need to provide the following arguments:\n\t 1) Path to your drupal installation\n\t 2) Username of the user that you want to give files/directories ownership\n\nNote: This script assumes that the group is the same as the username if your PHP is compiled to run as FastCGI. If this is different you need to modify it manually by editing this script or checking out forks on GitHub.\nUsage: bash ${0##*/} drupal_path user_name\n"

#echo "Refer to https://www.Drupal.org/node/244924"

if [ -z "${path}" ] || [ ! -d "${path}/sites" ] || [ ! -f "${path}/core/core.api.php" ]; then
	echo "Please provide a valid drupal path"
	echo -e $help
	exit
fi

if [ -z "${user}" ] || [ "$(id -un ${user} 2>/dev/null)" != "${user}" ]; then
	echo "Please provide a valid user"
	echo -e $help
	exit
fi

cd $path

#echo -e "Changing ownership of all contents of "${path}" :\n user => "${user}" \t group => "${group}"\n"
chown -R ${user}:${group} .
echo "Changing permissions of all directories inside "${path}" to "755"..."
find . -type d -exec chmod u=rwx,go=rx {} \;
echo -e "Changing permissions of all files inside "${path}" to "644"..."
find . -type f -exec chmod u=rw,go=r {} \;

cd sites

echo "Changing permissions of "files" directories in "${path}/sites" to "775"..."
find . -type d -name files -exec chmod ug=rwx,o=rx '{}' \;
echo "Changing permissions of all files inside all "files" directories in "${path}/sites" to "664"..."
find . -name files -type d -exec find '{}' -type f \; | while read FILE; do chmod ug=rw,o=r "$FILE"; done
echo "Changing permissions of all directories inside all "files" directories in "${path}/sites" to "775"..."
find . -name files -type d -exec find '{}' -type d \; | while read DIR; do chmod ug=rwx,o=rx "$DIR"; done
