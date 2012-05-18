SELECT * INTO OUTFILE '/home/ror/ex/spree_export.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'
from jos_al_import
WHERE (tip_tov = 2 );