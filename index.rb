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
#log.debug "Log file created"
#--------/FIRST INIT------------------

# получаем первую порцию иформации с каталога Симы
$log.debug "Read catalog"
txt = open_or_download(url_catalog,PROXY)
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
#качаем то, что получили

  #подрежем массив для скорости
  pr.keep_if{|key,value| key == 'Цветы, флористика, декор' or key == "Пасха"}

multy_get_from_hash(pr.clone)

#занесем в базу верхний уровень
#mysql_connect("localhost", "root", "fduecn")
mmy = MyMySQL.new(M_HOST, M_USER, M_PASS, M_DB)
pr.each_pair do |key,value|
  mmy.insert_al({:product_name =>key, :product_url => value})

#парсим внутренности категорий (следующий уровень)
  content = open_or_download

end #проход по главным категориям



#  #заносим в базу второй уровень

  #заносим в базу товар

