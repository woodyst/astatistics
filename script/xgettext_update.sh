#!/bin/bash

xgettext.pl --output=lib/Astatistics/I18N/messages.pot --directory=lib/ --directory=root/
for i in lib/Astatistics/I18N/*.po; do
	msgmerge -U $i lib/Astatistics/I18N/messages.pot
done
