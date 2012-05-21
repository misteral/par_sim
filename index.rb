# encoding: utf-8

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'curb'
require 'logger'
require 'mysql2'
require 'csv'

Dir[File.dirname(__FILE__)+"/includes/*.rb"].each {|file| require file }

#--------CONSTANTS---------------
ROOT_PATH = File.dirname(__FILE__)
url_catalog={:name=>"catalog", :url=>"http://www.sima-land.ru/catalog.html"}
#--------/CONSTANTS---------------

#--------FIRST INIT------------------
$log = Logger.new(ROOT_PATH+"/log/log.txt", 'daily')
@mmy = MyMySQL.new(M_HOST, M_USER, M_PASS, M_DB)

#log.debug "Log file created"
#--------/FIRST INIT------------------

# ---получаем первую порцию иформации с каталога Симы
$log.debug "Read catalog"
txt = open_or_download(url_catalog,"",PROXY)
doc = Nokogiri::HTML(txt)
start = doc.xpath('//div[@class="text-catalog"]')
lvl0=[]
start.css('span div h3 a').each do |el1|
  lvl0 << {:product_name => el1.text, :product_url => el1["href"], :product_parent_id => 0}
  #pr[el1.text]= el1['href']
end

txt = nil
doc = nil
start = nil

#----------------1 уровень----------------------
lvl0.keep_if do |key|
  key[:product_name] == 'Интерьерные сувениры' or
  key[:product_name] == 'Праздники'
end
$log.debug ("Readed lvl0"+lvl0.size.to_s+" categories.")
puts ("Readed lvl0"+lvl0.size.to_s+" categories.")
lvl1 = parce_category(lvl0,1)
#---------------2 уровень ---------------------
lvl1.keep_if do |key|
  key[:product_name] == 'Коллекционные куклы' or #остаются эти остальные убираются
  key[:product_name] == 'День автомобилиста'
end
$log.debug ("Category 1 lvl for parsing "+lvl0.size.to_s)
puts ("Category 1 lvl for parsing "+lvl0.size.to_s)
lvl2 = parce_category(lvl1,2)
#--------------3 уровень ----------------------
#lvl2.keep_if do |key|
  #key[:product_name] == 'Куклы коллекционные от 30 см'
   #or key[:product_name] == 'День автомобилиста'
#end
$log.debug ("Category 2 lvl for parsing "+lvl1.size.to_s)
puts ("Category 2 lvl for parsing "+lvl1.size.to_s)
lvl3 = parce_category(lvl2,3,true)
#$log.debug ("Category 3 lvl for parsing "+lvl2.size.to_s)
#puts ("Category 3 lvl for parsing "+lvl2.size.to_s)
