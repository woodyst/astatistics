#!/bin/bash

sudo /etc/init.d/apache2 restart & tail -f /var/log/apache2/error.log
