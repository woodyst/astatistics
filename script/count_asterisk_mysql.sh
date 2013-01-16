#!/bin/bash

watch -n1 '
for TABLE in `mysql -u root -p4321 asterisk -e "show tables" | grep -v Tables_in`; do mysql -u root -p4321 asterisk -e "select count(*) as $TABLE from $TABLE"; done
'
