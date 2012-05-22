select pr.*, gr.product_name as category INTO OUTFILE '/tmp/spree_export.csv'
FIELDS TERMINATED BY '\t' ESCAPED BY '\\' LINES TERMINATED BY '\n'
from jos_al_import as pr, jos_al_import as gr
where pr.product_isgroup = false and gr.product_id = pr.product_parent_id;


select tov.product_sku as sku, tov.product_desc as desk tov.full_image as image, tov.product_name as name, tov.product_price as price, tov.product_margin as margin
,CONCAT_WS(" > ", lv2.product_name, lv1.product_name,lv0.product_name) as category
 from jos_al_import tov
   left join jos_al_import lv0 ON tov.product_parent_id =lv0.product_id
   left join jos_al_import lv1 ON lv0.product_parent_id =lv1.product_id
   left join jos_al_import lv2 ON lv1.product_parent_id =lv2.product_id
where tov.product_isgroup = false and


  sku varchar(64), - артикул
  desk text(65535), - описание
  full_image varchar(255), - url картинки где взять
  product_name varchar(255), - имя
  price float(12, 0), - цена для нас(себестоимось)
  margin float(12, 0) default 1.8, - маржа либо алгоритм расчета полной цены
  category varchar(255), - категория в виде Электроника > Принтеры > HP