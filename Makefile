# please make sure to change the sudo password into your sudo password

PASSWORD ?= 123 

default: whywebscli

whywebscli:
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew install node
	brew install wget
	php -v
	curl -sS http://getcomposer.org/installer | php -- --filename=composer
	echo 123 | sudo -S chmod a+x composer
	echo 123 | sudo -S mv composer /usr/local/bin/composer
	echo 'Thank you for using Whywebs Drupal installation.'
