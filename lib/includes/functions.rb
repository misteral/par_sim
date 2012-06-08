# encoding: utf-8
module ImportSima
  #url - хеш значений :name - имя :url - откуда качать
  # proxy - прокси
  # path - добавочный path/для уровней
  def open_or_download(url,path="",proxy="")
    path_for = ROOT_PATH+"/dw-sima/"+path
    Dir.mkdir(path_for) unless File.exists?(path_for)
    url_name = url[:url][/(?<=http:\/\/www.sima-land.ru\/)(.+)/].gsub(/\//, "_").gsub(/\.html/,"")
    file_name = path_for+url_name+".html"
    if File.exists?(file_name) and !File.zero?(file_name)
      text = open(file_name) { |f| f.read }
    else
      fr = File.new(file_name, "w+")
      begin
      if proxy.empty?
        content = open(url[:url])
        else
        content = open(url[:url], :proxy => proxy)
      end
      #the_status = content.status[0]
      rescue OpenURI::HTTPError => the_error
      # some clean up work goes here and then..
      the_status = the_error.io.status[0] # => 3xx, 4xx, or 5xx
      # the_error.message is the numeric code and text in a string
      $log.error "Whoops got a bad status code #{the_error.message} file download fail, status #{the_status}"
      abort("File #{url} download fail")
      end
      #do_something_with_status(the_status)

      text = content.read
      File.open(file_name, 'w') {|f| f.write(text) }
    end

    text
  end


  def multy_get_from_hash(urls,path = "",proxy="")
    path_for = FILES_PATH+path
    Dir.mkdir(path_for) unless File.exists?(path_for) #создание директории когда ее нет

    urls.each do |key, value|
      #puts "ds"
      url_name = value[/(?<=http:\/\/www.sima-land.ru\/)(.+)/].gsub(/\//, "_").gsub(/\.html/,"")
      file_name = path_for+url_name+".html"
      #file_name = path_for+key+".html"
      if File.exists?(file_name) and !File.zero?(file_name)
        urls.delete(key)
      end
    end
    all_useragents = [
   	"Opera/9.23 (Windows NT 5.1; U; ru)",
   	"Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.8.1.8) Gecko/20071008 Firefox/2.0.0.4;MEGAUPLOAD 1.0",
   	"Mozilla/5.0 (Windows; U; Windows NT 5.1; Alexa Toolbar; MEGAUPLOAD 2.0; rv:1.8.1.7) Gecko/20070914 Firefox/2.0.0.7;MEGAUPLOAD 1.0",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; MyIE2; Maxthon)",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; MyIE2; Maxthon)",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; MyIE2; Maxthon)",
   	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; WOW64; Maxthon; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506; Media Center PC 5.0; InfoPath.1)",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; MyIE2; Maxthon)",
   	"Opera/9.10 (Windows NT 5.1; U; ru)",
   	"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2.1; aggregator:Tailrank; http://tailrank.com/robot) Gecko/20021130",
   	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.8) Gecko/20071008 Firefox/2.0.0.8",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; MyIE2; Maxthon)",
   	"Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.8.1.8) Gecko/20071008 Firefox/2.0.0.8",
   	"Opera/9.22 (Windows NT 6.0; U; ru)",
   	"Opera/9.22 (Windows NT 6.0; U; ru)",
   	"Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.8.1.8) Gecko/20071008 Firefox/2.0.0.8",
   	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; MRSPUTNIK 1, 8, 0, 17 HW; MRA 4.10 (build 01952); .NET CLR 1.1.4322; .NET CLR 2.0.50727)",
   	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)",
   	"Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9"
   	];
    if !urls.empty?
    m = Curl::Multi.new
    m.pipeline = true
    #pbar = ProgressBar.new("Download urls", urls.size)

    m.max_connects = 100
    #responses = {}
    urls.each_pair do |key, value|
#      responses[value] = ""
      c = Curl::Easy.new(value) do|curl|
        curl.follow_location = true
        curl.proxy_url = proxy if !proxy.empty?
        curl.connect_timeout = 100
        curl.headers["Referer"]= "http://www.yandex.ru"
        curl.useragent = all_useragents.sample
        curl.on_body {|d| File.open(path_for+value[/(?<=http:\/\/www.sima-land.ru\/)(.+)/].gsub(/\//, "_").gsub(/\.html/,"")+'.html', 'a') {|f| f.write d} }
        curl.on_failure {|response, err| $log.error "Erroor download #{key}. We have failure.  The response code is #{response.response_code}. Error is: #{err.inspect}"}
        #curl.on_progress {|dl_total, dl_now, ul_total, ul_now| puts "dl_total-#{dl_total} --- dl_now-#{dl_now}";sleep 3; puts}
      end
      m.add(c)
    end
    m.perform

    #urls.each do|url|
    #   puts responses[url]
    # end

    true
    else
      false #файлы все существуют ничего качать не нужно
    end
  end

  #качает затем парсит заданный уровень,, заносит в базу их и возвращает массив со следующим уровнем
  # если ласт парсит как последнюю категорию и заносит товар
  def parce_category(list_cat_arr,lvl, last = false)
    pr2_hash={}
    if last
      pr_count = 0
      pr_skip = 0
      list_cat_arr.each {|h| pr2_hash[h[:product_name]]=h[:product_url]+"?limit=500"} #пробежимся выдернем ключ значение в список для закачки
    else
      list_cat_arr.each {|h| pr2_hash[h[:product_name]]=h[:product_url]} #пробежимся выдернем ключ значение в список для закачки
    end
    multy_get_from_hash(pr2_hash.clone,lvl.to_s+"/",PROXY)  #качаем файлы
    pr2_hash = nil
    pr2=[] # массив со вторым уровнем
    list_cat_arr.each do |v|
    #---занесем в базу верхний уровень
      if v[:product_url].include? ('igrushki')   #определим тип товара игрушка или сувенирка
        v[:tip_tov] = 1
      else v[:tip_tov] = 2
      end
      returned_id =  @mmy.insert_al(v) #занесем в базу
      if last
        result = parce_product(v,lvl,returned_id)
        pr_count = pr_count + result[:count]
        pr_skip = pr_skip + result[:skip]
      else
        doc = Nokogiri::HTML(open_or_download({ :url => v[:product_url], :name => v[:product_name] }, lvl.to_s+"/",PROXY))
        doc.xpath('//div[@class="item-list-categories thumbs120"]/ins/div/span/a').each do |el2|
          pr2 << {:product_name => el2["title"], :product_url => el2["href"], :product_parent_id => returned_id}
        end
      end

    end #проход по категориям
    cont = nil
    doc = nil
    if last
      $log.debug ("Goods all "+pr_count.to_s+", goods skiped " + (pr_count-pr_skip).to_s)
      puts ("Goods all "+pr_count.to_s+", goods skiped " + (pr_count-pr_skip).to_s)
      else
        pr2
    end
  end

  def parce_product(h,lvl,returned_id)
    pr_count = 0
    pr_skip = 0
    if h[:product_url].include? ('igrushki')   #определим тип товара игрушка или сувенирка
      tip_tov = 1
    else tip_tov = 2
    end
    doc = Nokogiri::HTML(open_or_download({ :url => h[:product_url]+"?limit=500", :name => h[:product_name] }, lvl.to_s+"/",PROXY))
    skip = false
    doc.xpath("//div[@class='item-list-wrapper']/table[@class='item-list-table']/tbody/tr").each do |el3|
      pis = {}
      pis[:tip_tov] = tip_tov
      pre_product_name= el3.xpath("td[@class='item-list-name']/a").text
      pis[:product_url] = el3.xpath("td[@class='item-list-name']/a")[0]['href']
      pis[:product_status] = 1
      pis[:product_parent_id] = returned_id
      pis[:product_is_group] = 0
      pre_product_ed= el3.xpath("td[@class='item-list-qty']").text.strip
      pre_price_min = el3.xpath("td[@class='item-list-qty']").text.strip
      pre_price_min_d = el3.xpath("td[@class='item-list-qty']/span").text.strip
      pis[:product_price] = el3.xpath("td[@class='item-list-price']/div").text.strip.to_f
      pis[:product_sku] =  el3["itemid"].strip
      pre_product_desc = (el3.xpath("td[@class='item-list-name']").text.strip)
      pis[:product_ost] = (el3.xpath("td[@class='item-list-balance']").text).strip
      pre_product_desc_vnabore = (el3.xpath("td[@class='item-list-pack']").text).strip

      pre_price_min = pre_price_min.gsub(/выбрать цвет/,"")
      if pre_price_min.include? ("по")
        pis[:package] = pre_price_min_d

        pis[:product_min] = pre_price_min_d
      end
      if pre_price_min.include? ("минимум")
        pis[:product_min] = pre_price_min_d
      end
      pis[:product_name]  = pre_product_name.gsub(/#{pis[:product_sku]}/,"").strip
      pis[:product_ost] = pis[:product_ost].gsub(/Новинка/,"").strip

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
        if !dop1.empty? and dop2.empty?
          dop1= dop1+", "
        end
        pis[:product_desc] = dop1+dop2+dop3
      else
        if !dop2.empty? or !dop1.empty?
          pis[:product_desc] = dop1 + dop2
        else
          pis[:product_desc] = ""
        end
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
      pr_count = pr_count+1
      #заносим в базу товар
      if !skip
        pr_skip = pr_skip+1
        file_image = download_image_add_logo(pis[:product_sku])
        pis[:product_full_image] = file_image if file_image
        @mmy.insert_al(pis)
        #качаем изображение и добавляем лого
      end
    end #проход по товарам

    arr = {:count =>pr_count, :skip => pr_skip}
  end  #parse_product

  def swap_sku(sku)
      sku = "1"+sku.to_s.reverse
  end

  def re_swap_sku(sku)
    sku = sku[1..sku.size-1].reverse
  end

  def create_folders(provider,path)
    if provider == "file"
      Dir.mkdir(IMAGE_PATH) unless File.exists?(IMAGE_PATH)
      Dir.mkdir(IMAGE_PATH+'original') unless File.exists?(IMAGE_PATH+'original')
      Dir.mkdir(IMAGE_PATH+'with_logo') unless File.exists?(IMAGE_PATH+'with_logo')
    end
  end

  def download_image_add_logo(sku)
    url = sima_image_url + sku +".jpg"
    file_name = IMAGE_PATH_ORIGINAL + sku +".jpg"
    if !File.exists?(file_name) or File.zero?(file_name)
      begin

        open(file_name, 'wb') do |file|
          if PROXY.empty?
            file << open(url).read
            else
            file << open(url, :proxy => PROXY).read
          end
        end
      rescue OpenURI::HTTPError => the_error

      the_status = the_error.io.status[0] # => 3xx, 4xx, or 5xx
      # the_error.message is the numeric code and text in a string
      $log.error "Whoops got a bad status code #{the_error.message} image file download fail, status #{the_status}"
      puts("image #{url} with sku #{sku} download fail")
      end
    end
    add_logo_and_copy_to_with_logo_folder(sku)
  end

  def add_logo_and_copy_to_with_logo_folder(sku)
    begin
      original_file = IMAGE_PATH_ORIGINAL + sku +".jpg"
      save_filename = IMAGE_PATH_WITH_LOGO + swap_sku(sku) +".jpg"
      if !File.exists?(save_filename) or File.zero?(save_filename)
        #white_bg = Magick::Image.new(600, 600)
        clown = Magick::Image.read(original_file).first
        logo = Magick::Image.read(LOGO_IMAGE).first
        clown = clown.composite(logo, 0, 0, Magick::OverCompositeOp)
        #clown.resize(600,600)
        clown.write(save_filename)
        system ("convert #{save_filename} -resize 600x600 -size 600x600 xc:#fff +swap -gravity center -composite #{save_filename}")
      end
      return save_filename
    rescue Exception => e
      $log.error "Unable to save_images data #{save_filename} because #{e.message}"
    end
  end


  def upload_to_csv (arr,file)
    file = ROOT_PATH + file
    #fr = File.new(file, "w+")
    File.delete(file) if File.exist? file
    File.open(file,'w'){ |f| f << arr.map{ |row| row.join("\t") }.join("\n") }
  end

 def save_to_csv
      reu = @mmy.get_result
      arr_tov = []
      reu.each(:as => :array) do |row|
        arr_tov << row
      end
      exf =  EXPORT_FILE
      upload_to_csv(arr_tov, exf)
 end
end