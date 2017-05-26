-include env_make

.PHONY: whywebs_drupal

drupal ?= 7
php ?= 5.6

default: whywebs_test

whywebs_test:
	cd ./whywebs_drupal/$(drupal)/$(php) && ./run.sh