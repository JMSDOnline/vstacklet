#!/bin/bash
#
# Quick permissions for /srv/www 
#
# Original Credits to ::
# GitHub:   https://github.com/jbradach/quick-lemp
#

echo 'This script will add a new www-data group and sets permissions for/srv/www/'
read -p "${bold}Do you want to continue?[y/N]${normal} " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo 'Exiting...'
  exit 1
fi
echo 'Checking permissions...'
echo
if [[ $EUID -ne 0 ]]; then
  echo 'This script must be run with root privileges.' 1>&2
  echo 'Exiting...'
  exit 1
fi
echo 'Adding www-data'
groupadd www-data
echo
echo 'If you want to add a user to the group, enter their username.'
read -p "Username[$SUDO_USER]: " -r newuser
if [ -z "$newuser" ]; then
  newuser=$SUDO_USER
fi
usermod -a -G www-data $newuser

# Change the ownership of everything under /var/www to root:www-data
chown www-data:www-data -R /srv/www/public/_
chmod 2775 /srv/www/public/_
find /srv/www/public/_ -type d -exec chmod 2775 {} +
find /srv/www/public/_ -type f -exec chmod 0664 {} +
chmod 755 /srv/www/public/_/wp-content

echo 'Done! Consider changing umask to 0002.'
