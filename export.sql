select pr.*, gr.product_name as category INTO OUTFILE '/tmp/spree_export.csv'
FIELDS TERMINATED BY '\t' ESCAPED BY '\\' LINES TERMINATED BY '\n'
from jos_al_import as pr, jos_al_import as gr
where pr.product_isgroup = false and gr.product_id = pr.product_parent_id;