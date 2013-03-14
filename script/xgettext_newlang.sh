#!/bin/bash

echo -n "Language suffix: "
read S
if [ "z$S" != "z" ]; then
	if [ -f lib/Astatistics/I18N/$S.po ]; then
		echo "Language file lib/Astatistics/I18N/$S.po already exists."
		exit 1
	else
		msginit --input=lib/Astatistics/I18N/messages.pot --output=lib/Astatistics/I18N/$S.po --locale=$S
	fi
fi
