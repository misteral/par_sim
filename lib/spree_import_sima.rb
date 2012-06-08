# encoding: utf-8

module ImportSima
#require 'spree_core'
#require 'spree_import_sima/engine'

#require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'curb'
require 'logger'
require 'mysql2'
require 'csv'
require 'RMagick'

#ROOT_PATH = File.dirname(__FILE__)
Dir[File.dirname(__FILE__)+"/includes/*.rb"].sort.each {|file| require file }



def perform
    #--------CONSTANTS---------------
    url_catalog={:name=>"catalog", :url=>"http://www.sima-land.ru/catalog.html"}

    #--------/CONSTANTS---------------

    #--------FIRST INIT------------------
    $log = Logger.new(LOG_PATH+"log_sima.txt", 'daily')
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
    #----------------------------------Фильтры на парсинг категорий-----------------
    trimer_lvl0 = [
        'Интерьерные сувениры',
        'Праздники',
        'Хозяйственные товары',
        'Сувениры российских поставщиков',
        'Бизнес-сувениры',
        'Свечи и подсвечники',
        'Посуда и кухонные принадлежности',
        'Товары и игрушки для малышей',
        'Конструкторы',
        'Игрушки российского производства',
        'Товары для детей',
        'Детское творчество'


    ]
    trimer_lvl1 = [
        'Коллекционные куклы',
        'День автомобилиста',
        'Электротовары',
        'Народные промыслы',
        'Наборы для спиртных напитков',
        'Игры',
        'Наборы настольные',
        'Интерьерные сувениры',
        'Обучающие и развивающие игрушки',
        'Деревянная игрушка',
        'Палатки и корзины для игрушек',
            #детское творчество
        'Всё для лепки', 'Доски магнитные и магниты','Кукольный театр','Музыка','Наборы "Сделай сам"','Рисование', 'Рукоделие','Аппликации','Kukumba','Украшения своими руками',
        'Панно', 'Термомозаика', 'Гравюры из металлопластика','Изделия из дерева', 'Поделки из бумаги'
    ]
    #----------------1 уровень----------------------
    lvl0.keep_if do |key|
      trimer_lvl0.include?(key[:product_name])
    end
    $log.debug ("Readed lvl0 "+lvl0.size.to_s+" categories.")
    puts ("Readed lvl0 "+lvl0.size.to_s+" categories.")
    lvl1 = parce_category(lvl0,1)
    #---------------2 уровень ---------------------
    lvl1.keep_if do |key|
      trimer_lvl1.include?(key[:product_name])
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

    #выгрузим все в csv

    save_to_csv

 end

end

