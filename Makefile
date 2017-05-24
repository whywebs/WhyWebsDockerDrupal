-include env_make

.PHONY: whywebs_drupal

drupal ?= 7
php ?= 5.6
cmd ?= phing

default: whywebs_drupal

whywebs_drupal:
	cd ./whywebs_drupal/$(drupal)/$(php) && ./run.sh