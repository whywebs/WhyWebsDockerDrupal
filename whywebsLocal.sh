#!/bin/sh

BASEURL='$base_url="http://whywebs.dev:8080";'
LOCALURL='192.168.99.100 whywebs.dev'
SUDOPASS="123"

echo $SUDOPASS | sudo -S chmod -Rv 777 deploy/sites/default/files
echo $SUDOPASS | sudo -S chmod -Rv 755 deploy/sites/default/settings.php
echo $SUDOPASS | sudo -S echo $BASEURL >> deploy/sites/default/settings.php
echo $SUDOPASS | sudo -S sh -c "echo "$LOCALURL" >> /etc/hosts"
echo $SUDOPASS | sudo -S apachectl restart


echo 'Your website on http://whywebs.dev:8080 is ready enjoy !! by Mutasem Elayyoub'