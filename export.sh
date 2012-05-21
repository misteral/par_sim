#!/bin/bash

#mysqldump --user=root --password=ewre4 --fields-escaped-by='\\' --fields-terminated-by='\t' --lines-terminated-by='\n' --default-character-set=utf8 "--tab=/tmp" sundmart jos_al_import

rm /tmp/spree_export.csv
mysql -uroot -p sundmart < export.sql