# encoding: utf-8

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'curb'
require 'logger'
require 'mysql2'

Dir[File.dirname(__FILE__)+"/includes/*.rb"].each {|file| require file }

#--------CONSTANTS---------------
ROOT_PATH = File.dirname(__FILE__)
url_catalog={:name=>"catalog", :url=>"http://www.sima-land.ru/catalog.html"}
PROXY = 'http://10.44.33.209:8080'
M_HOST = "localhost"
M_USER = "root"
M_PASS = "fduecn"
M_DB = "sundmart"
#--------/CONSTANTS---------------

#--------FIRST INIT------------------
$log = Logger.new(ROOT_PATH+"/log/log.txt", 'daily')
mmy = MyMySQL.new(M_HOST, M_USER, M_PASS, M_DB)
#log.debug "Log file created"
#--------/FIRST INIT------------------

# ---получаем первую порцию иформации с каталога Симы
$log.debug "Read catalog"
txt = open_or_download(url_catalog)
doc = Nokogiri::HTML(txt)
start = doc.xpath('//div[@class="text-catalog"]')[0]
pr={}
start.css('span div h3 a').each do |el1|
  pr[el1.text]= el1['href']
end

$log.debug ("Readed "+pr.size.to_s+"categories.")
txt = nil
doc = nil
start = nil
#---качаем то, что получили
  #---подрежем массив для скорости
  pr.keep_if{|key,value| key == 'Цветы, флористика, декор' or key == "Пасха"}
multy_get_from_hash(pr.clone,"1/")

pr2=[] # массив со вторым уровнем
pr.each_pair do |key,value|
#---занесем в базу верхний уровень
  returned_id =  mmy.insert_al({:product_name =>key, :product_url => value})
#---парсим внутренности категорий (2 уровень)
  doc_hash = Hash.new()
  doc = Nokogiri::HTML(open_or_download({ :url => value, :name => key }, "1/"))
  doc.xpath('//div[@class="item-list-categories thumbs120"]/ins/div/span/a').each do |el2|
    #pr2[el2["title"]] = el2["href"]
    pr2 << {:product_name => el2["title"], :product_url => el2["href"], :parent_id => returned_id}
  end
end #проход по главным категориям
cont = nil
doc = nil

#  качаем третий уровень с товаром
#----выдергиваем хеш name=>url
pr2_hash={}
pr2.each {|h| pr2_hash[h[:product_name]]=h[:product_url]+"?limit=500"}
multy_get_from_hash(pr2_hash,"2/") #качаем третий уровень
#--заносим в базу второй уровень
pr2_hash = nil
pr3=[]
pr2.each do |h|
  returned_id = mmy.insert_al(h)  #заносим а базу второй уровень
  # парсим третий уровень
  doc = Nokogiri::HTML(open_or_download({ :url => h[:product_url], :name => h[:product_name] }, "2/"))
  doc.xpath("//div[@class='item-list-wrapper']/table[@class='item-list-table']/tbody/tr").each do |el3|
    product_name= el3.xpath("td[@class='item-list-name']/a").text
    product_url = el3.xpath("td[@class='item-list-name']/a")[0]['href']
    product_status = 4
    product_parent_id = returned_id
    product_isgroup = 0
    product_ed = el3.xpath("td[@class='item-list-qty']").text.strip
    product_min = el3.xpath("td[@class='item-list-qty']/span").text
    product_price = el3.xpath("td[@class='item-list-price']/div").text
    product_sku =  el3["itemid"]
    pre_product_desc_razm = (el3.xpath("td[@class='item-list-name']").text.strip).match(/Размеры:(.+?)Материал:/)[1]
    pre_product_desc_mater = (el3.xpath("td[@class='item-list-name']").text.strip).match(/Материал:(.+)/)[1]
    pre_product_desc_vnabore = (el3.xpath("td[@class='item-list-pack']").text).strip.match(/\((.+)\)/)[1]
    product_ost = (el3.xpath("td[@class='item-list-balance']").text).strip

  end
end #проход по внутренним категориям

  #заносим в базу товар

