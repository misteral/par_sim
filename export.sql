SELECT * INTO OUTFILE '/tmp/spree_export.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'
from jos_al_import
WHERE (tip_tov = 1 );