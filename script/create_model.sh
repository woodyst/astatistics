#!/bin/bash

script/astatistics_create.pl model Astatistics DBIC::Schema Astatistics::Schema create=static dbi:SQLite:db/astatistics.db
