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
  sqip = false
  pis = {}
  doc = Nokogiri::HTML(open_or_download({ :url => h[:product_url], :name => h[:product_name] }, "2/"))
  doc.xpath("//div[@class='item-list-wrapper']/table[@class='item-list-table']/tbody/tr").each do |el3|
    pis[:product_name]= el3.xpath("td[@class='item-list-name']/a").text
    pis[:product_url] = el3.xpath("td[@class='item-list-name']/a")[0]['href']
    pis[:product_status] = 4
    pis[:product_parent_id] = returned_id
    pis[:product_is_group] = 0
    pis[:product_ed] = el3.xpath("td[@class='item-list-qty']").text.strip
    pis[:product_min] = el3.xpath("td[@class='item-list-qty']/span").text.strip
    pis[:product_price] = el3.xpath("td[@class='item-list-price']/div").text.strip.to_i
    pis[:product_sku] =  el3["itemid"]
    pre_product_desc_razm = "Размер: "+(el3.xpath("td[@class='item-list-name']").text.strip).match(/Размеры:(.+?)Материал:/)[1]
    pre_product_desc_mater = "Материал: "+(el3.xpath("td[@class='item-list-name']").text.strip).match(/Материал:(.+)/)[1]
    pre_product_desc_vnabore = (el3.xpath("td[@class='item-list-pack']").text).strip.match(/\((.+)\)/)[1].strip
    pis[:product_ost] = (el3.xpath("td[@class='item-list-balance']").text).strip

    dop1 = (!pre_product_desc_mater.empty?) ? pre_product_desc_mater+". ": ""
    dop2 = (!pre_product_desc_razm.empty?) ? pre_product_desc_razm+". ": ""
    dop3 = (!pre_product_desc_vnabore.empty?) ? pre_product_desc_vnabore+". ": ""
    dop3[0] = "В"
    pis[:product_desc] = dop1 + dop2+ dop3


    #---не берем если с маленьким остатком
    if !pis[:product_ost].is_a?(String)
      begin
      if product_ost.to_i < 50
        skip=true
      end
      rescue
        skip=true
      end
    else
      if pis[:product_ost] =='от 0 до 10' or pis[:product_ost] =='от 10 до 50'	or pis[:product_ost] =='от 50 до 100' or pis[:product_ost]=="Мало"
        skip=true
      end
    end
    # --- наценка на товар
    pis[:product_margin] = 1.3 if pis[:product_price] > 2000
    pis[:product_margin] = 1.3 if pis[:product_price] <=2000
    pis[:product_margin] = 1.4 if pis[:product_price] <=1500
    pis[:product_margin] = 1.5 if pis[:product_price] <=1000
    pis[:product_margin] = 1.6 if pis[:product_price] <=700
    pis[:product_margin] = 1.6 if pis[:product_price] <=500
    pis[:product_margin] = 1.7 if pis[:product_price] <=300
    pis[:product_margin] = 1.8 if pis[:product_price] <=100
    pis[:product_margin] = 2   if pis[:product_price] <=50
    pis[:product_margin] = 2.3 if pis[:product_price] <=10

    puts "d"

  end #проход по товарам


end #проход по подчиненным категориям

  #заносим в базу товар

