#!/bin/bash

echo -n "Language suffix: "
read S
if [ "z$S" != "z" ]; then
	msginit --input=lib/Astatistics/I18N/messages.pot --output=lib/Astatistics/I18N/$S.po --locale=$S
fi
