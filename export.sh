#!/bin/bash

mysqldump --user=root --password=fduecn --fields-escaped-by='\\' --fields-terminated-by='\t' --lines-terminated-by='\n' --default-character-set=utf8 "--tab=/tmp" sundmart jos_al_import

#su mysql rm /tmp/spree_export.csv
#DBS=`mysql -uroot -pfduecn sundmart < export.sql`