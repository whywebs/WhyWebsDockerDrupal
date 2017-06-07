#!/bin/sh

# please make sure to change the sudo password into your sudo password
BASEURL = $base_url="whywebs.dev";
LOCALURL = 192.168.99.100 whywebs.dev
SUDOPASS = 123

default: whywebscli

whywebscli:
	echo $(SUDOPASS) | sudo -S chmod -Rv 777 deploy/sites/default/files
	echo $(SUDOPASS) | sudo -S chmod -Rv 755 deploy/sites/default/settings.php
	echo $(SUDOPASS) | sudo -S echo $(BASEURL) >> deploy/sites/default/settings.php
	echo $(SUDOPASS) | sudo -S sh -c "echo "$(LOCALURL)" >> /etc/hosts"
	echo $(SUDOPASS) | sudo -S cp whywebs-drupal/whywebs.local.dev.conf /private/etc/apache2/other/
	echo $(SUDOPASS) | sudo -S apachectl restart

	echo '##################################################################################'
	echo ''
	echo 'Your website on http://192.168.99.100/ is ready enjoy it !! by Mutasem Elayyoub'
	echo ''
	echo '##################################################################################'