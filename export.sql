select pr.*, gr.product_name as category INTO OUTFILE '/tmp/spree_export.csv'
FIELDS TERMINATED BY '\t' ESCAPED BY '\\' LINES TERMINATED BY '\n'
from jos_al_import as pr, jos_al_import as gr
where pr.product_isgroup = false and gr.product_id = pr.product_parent_id;


-- select *,CONCAT_WS(" > ", lv2.product_name, lv1.product_name,lv0.product_name) as category
-- from jos_al_import tov
--   left join jos_al_import lv0 ON tov.product_parent_id =lv0.product_id
--   left join jos_al_import lv1 ON lv0.product_parent_id =lv1.product_id
--   left join jos_al_import lv2 ON lv1.product_parent_id =lv2.product_id
-- where tov.product_isgroup = false