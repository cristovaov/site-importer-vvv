#!/bin/bash
#
# Custom provision for site import.
#
# This script was taken and modified from '{vvv-dir}/provision/provision.sh'

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds="$(date +%s)"

# Find new sites to setup.
# Kill previously symlinked Nginx configs
# We can't know what sites have been removed, so we have to remove all
# the configs and add them back in again.
find /etc/nginx/custom-sites -name 'vvv-auto-*.conf' -exec rm {} \;

# Look for site setup scripts
for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'vvv-init.sh'); do
	DIR="$(dirname $SITE_CONFIG_FILE)"
	(
		cd $DIR
		source vvv-init.sh
	)
done

# Look for Nginx vhost files, symlink them into the custom sites dir
for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'vvv-nginx.conf'); do
	DEST_CONFIG_FILE=${SITE_CONFIG_FILE//\/srv\/www\//}
	DEST_CONFIG_FILE=${DEST_CONFIG_FILE//\//\-}
	DEST_CONFIG_FILE=${DEST_CONFIG_FILE/%-vvv-nginx.conf/}
	DEST_CONFIG_FILE="vvv-auto-$DEST_CONFIG_FILE-$(md5sum <<< $SITE_CONFIG_FILE | cut -c1-32).conf"
	# We allow the replacement of the {vvv_path_to_folder} token with
	# whatever you want, allowing flexible placement of the site folder
	# while still having an Nginx config which works.
	DIR="$(dirname $SITE_CONFIG_FILE)"
	sed "s#{vvv_path_to_folder}#$DIR#" $SITE_CONFIG_FILE > /etc/nginx/custom-sites/$DEST_CONFIG_FILE
done

# RESTART SERVICES AGAIN
#
# Make sure the services we expect to be running are running.
echo -e "\nRestart Nginx..."
service nginx restart

# Parse any vvv-hosts file located in www/ or subdirectories of www/
# for domains to be added to the virtual machine's host file so that it is
# self aware.
#
# Domains should be entered on new lines.
echo "Cleaning the virtual machine's /etc/hosts file..."
sed -n '/# vvv-auto$/!p' /etc/hosts > /tmp/hosts
mv /tmp/hosts /etc/hosts
echo "Adding domains to the virtual machine's /etc/hosts file..."
find /srv/www/ -maxdepth 5 -name 'vvv-hosts' | \
while read hostfile; do
	while IFS='' read -r line || [ -n "$line" ]; do
		if [[ "#" != ${line:0:1} ]]; then
			if [[ -z "$(grep -q "^127.0.0.1 $line$" /etc/hosts)" ]]; then
				echo "127.0.0.1 $line # vvv-auto" >> /etc/hosts
				echo " * Added $line from $hostfile"
			fi
		fi
	done < $hostfile
done

end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Completed in "$(expr $end_seconds - $start_seconds)" seconds"
