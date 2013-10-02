#!/bin/bash

DATABASE=asterisk
USERNAME=asterisk
PASSWORD=4321
script/astatistics_create.pl model Asterisk DBIC::Schema Asterisk::Schema create=static dbi:mysql:dbname=$DATABASE $USERNAME $PASSWORD
