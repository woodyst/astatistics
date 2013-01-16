#!/bin/bash

EXCEPTIONS=${1+"$@"}

AST_MYSQL_FILE=`echo $0 | sed -e 's/\/[^\/]\+$/\/..\/db\/asterisk-mysql.sql/'`
echo "Dangerous!!! This script is about to remove your tables of asterisk MySQL database. Press <Return> to continue or <CTRL+C> to Abort."
read

for i in `mysql -u root -p4321 asterisk -e "show tables" | grep -v Tables_in`; do mysql -u root -p4321 asterisk -e "drop table $i"; done

mysql -f -u root -p4321 asterisk < ./$AST_MYSQL_FILE
