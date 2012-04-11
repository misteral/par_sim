require "rubygems"
require 'open-uri'
require 'nokogiri'
require 'logger'
Dir[File.dirname(__FILE__)+"/includes/*.rb"].each {|file| require file }

#--------CONSTANTS---------------
ROOT_PATH = File.dirname(__FILE__)
url_catalog={:name=>"catalog", :url=>"http://www.sima-land.ru/catalog.html"}
PROXY = 'http://10.44.33.209:8080'
#--------/CONSTANTS---------------

#--------FIRST INIT------------------
log = Logger.new(ROOT_PATH+"/log/log.txt", 'daily')
#log.debug "Log file created"
#--------/FIRST INIT------------------

# получаем первую порцию иформации с каталога Симы
log.debug "Read catalog"
txt = open_or_download(url_catalog,PROXY)
doc = Nokogiri::HTML(txt)
start = doc.xpath('//div[@class="text-catalog"]')[0]
pr={}
start.css('span div h3 a').each do |el1|
  pr[el1.text]= el1['href']
end

log.debug ("Readed "+pr.size.to_s+"categories.")

#качаем то, что получили

#занесем в базу верхний уровень

#качаем второй уровень

#парсим внутренности категорий (следующий уровень)

  #заносим в базу второй уровень

  #заносим в базу товар

