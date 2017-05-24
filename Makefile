-include env_make

.PHONY: whywebs_drupal

drupal ?= 7
php ?= 5.6
cmd ?= phing

default: test

test:
	cd ./whywebs_drupal/$(drupal)/$(php) && ./run.sh