#!/bin/bash

echo "Starting at `date`"
# Disabled because this kind of uninstallation is dangerous!!!
#if [ "z$1" == "z-u" ]; then
#	MODS_LIST=`sudo ls /root/.cpanplus/5.10.1/build/ | sed -e 's/-[^-]\+$//'`
#	sudo cpanp u $MODS_LIST
#else
	sudo apt-get install wkhtmltopdf libtest-nowarnings-perl libexpat-dev pkg-config libcairo-dev build-essential
	yes | sudo cpan install CPAN
	yes | sudo cpan CPANPLUS
	yes | sudo cpan Params::Validate
	yes | sudo cpan Moose
	yes | sudo cpan -fi DBIx::Class
	perl Makefile.PL build
	yes | sudo make
#fi
echo "Finishing at `date`"
