#!/bin/bash

#watch -n1 'mysql -u root -p4321 asterisk -e "select * from queue_log where id > ((select MAX(id) from queue_log) - 20 )"'
sudo tail -f /var/log/asterisk/queue_log
