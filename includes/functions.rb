# encoding: utf-8

  #url - хеш значений :name - имя :url - откуда качать
  # proxy - прокси
  # path - добавочный path/для уровней
  def open_or_download(url,path="",proxy="")
    path_for = ROOT_PATH+"/dw-sima/"+path
    Dir.mkdir(path_for) unless File.exists?(path_for)
    file_name = path_for+url[:name]+".html"
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
      @log.debug "Whoops got a bad status code #{the_error.message} Catalog download fail"
      abort("Catalog download fail")
      end
      #do_something_with_status(the_status)

      text = content.read
      File.open(file_name, 'w') {|f| f.write(text) }
    end

    text
  end


  def multy_get_from_hash(urls,path = "")
    path_for = ROOT_PATH+"/dw-sima/"+path
    Dir.mkdir(path_for) unless File.exists?(path_for) #создание директории когда ее нет

    urls.each_key do |key|
      file_name = path_for+key+".html"
      if File.exists?(file_name) and !File.zero?(file_name)
        urls.delete(key)
      end
    end
    if !urls.empty?
    m = Curl::Multi.new
    m.pipeline = true
    #responses = {}
    urls.each_pair do |key, value|
#      responses[value] = ""
      c = Curl::Easy.new(value) do|curl|
        curl.follow_location = true
        curl.on_body {|d| File.open(path_for+key+'.html', 'a') {|f| f.write d} }
#TODO: Надо сделать смену реферала и агента
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


