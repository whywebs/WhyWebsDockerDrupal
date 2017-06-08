#!/bin/sh

# please make sure to change the sudo password into your sudo password


LOCALURL = '192.168.99.100    whywebs.site'
# make sure to change the value below to your sudo password for local fixes
SUDOPASS = 123

default: whywebscli

whywebscli:
	echo $(SUDOPASS) | sudo -S chmod -Rv 777 deploy/sites/default/files
	echo $(SUDOPASS) | sudo -S chmod -Rv 755 deploy/sites/default/settings.php
	echo $(SUDOPASS) | sudo -S sh -c "echo "$(LOCALURL)" >> /etc/hosts"
	echo $(SUDOPASS) | sudo -S apachectl restart

#  built by  by Mutasem Elayyoub whywebs.com
	echo '##################################################################################'
	echo ''
	echo 'Your website on http://whywebs.dev/ is ready enjoy it !!'
	echo ' User name: admin  User password: admin '
	echo ''
	echo '##################################################################################'