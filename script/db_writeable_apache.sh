#!/bin/bash

sudo chgrp -R www-data db
sudo chmod 775 db
sudo chmod 664 db/astatistics.db
