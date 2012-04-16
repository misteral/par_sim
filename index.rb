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
  doc = Nokogiri::HTML(open_or_download({ :url => h[:product_url], :name => h[:product_name] }, "2/"))
  doc.xpath("//div[@class='item-list-wrapper']/table[@class='item-list-table']/tbody/tr").each do |el3|
 #   begin
    pis = {}
    pre_product_name= el3.xpath("td[@class='item-list-name']/a").text
    pis[:product_url] = el3.xpath("td[@class='item-list-name']/a")[0]['href']
    pis[:product_status] = 4
    pis[:product_parent_id] = returned_id
    pis[:product_is_group] = 0
    pre_product_ed= el3.xpath("td[@class='item-list-qty']").text.strip
    pre_price_min = el3.xpath("td[@class='item-list-qty']").text.strip
    pis[:product_price] = el3.xpath("td[@class='item-list-price']/div").text.strip.to_f
    pis[:product_sku] =  el3["itemid"].strip
    pre_product_desc = (el3.xpath("td[@class='item-list-name']").text.strip)
    pis[:product_ost] = (el3.xpath("td[@class='item-list-balance']").text).strip
    pre_product_desc_vnabore = (el3.xpath("td[@class='item-list-pack']").text).strip

    pis[:product_min] = pre_price_min.gsub(/выбрать цвет/,"")
    pis[:product_name]  = pre_product_name.gsub(/#{pis[:product_sku]}/,"").strip
    if pre_product_ed.include?("набор")
    pis[:product_ed] = "набор"
    else
      if pre_product_ed.include?("упак")
        pis[:product_ed] = "упак"
      else pis[:product_ed] = "шт"
      end
    end

    dop1 = pre_product_desc[/Материал:(.+)/,1]
    dop2 = pre_product_desc[/Размеры:(.+?)Материал:/,1]
    dop3 = pre_product_desc_vnabore[/\((.+)\)/,1]

    dop1 = (dop1) ? dop1.strip.downcase : ""
    dop2 = (dop2) ? dop2.strip.downcase : ""
    dop3 = (dop3) ? dop3.strip.downcase : ""

    if !dop1.empty? and !dop2.empty?
      dop2 = ", "+dop2
    end
    if !dop3.empty? and !dop2.empty?
      dop2 = dop2+", "
    end
    if !dop3.empty?
      pis[:product_desc] = dop1+dop2+dop3 +"."
    else
      pis[:product_desc] = dop1 + dop2+"."
    end

    if pis[:product_ost].to_i < 50 and pis[:product_ost].to_i != 0
        skip=true
    end
    if pis[:product_ost] =='от 0 до 10' or pis[:product_ost] =='от 10 до 50'	or pis[:product_ost] =='от 50 до 100' or pis[:product_ost]=="Мало"
      skip=true
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

     #заносим в базу товар
    if !skip
      mmy.insert_al(pis)
    end
=begin
    rescue
      puts "errr"
    end
=end
  end #проход по товарам


end #проход по подчиненным категориям



