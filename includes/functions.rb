# encoding: utf-8
  def open_or_download(url,proxy)
    file_name = ROOT_PATH+"/dw-sima/"+url[:name]+".html"
    if File.exists?(file_name) and !File.zero?(file_name)
      text = open(file_name) { |f| f.read }
    else
      fr = File.new(file_name, "w+")
      begin
      content = open(url[:url], :proxy => proxy)
      #the_status = content.status[0]
      rescue OpenURI::HTTPError => the_error
      # some clean up work goes here and then..
      the_status = the_error.io.status[0] # => 3xx, 4xx, or 5xx
      # the_error.message is the numeric code and text in a string
      log.debug "Whoops got a bad status code #{the_error.message} Catalog download fail"
      abort("Catalog download fail")
      end
      #do_something_with_status(the_status)

      text = content.read
      File.open(file_name, 'w') {|f| f.write(text) }
    end

    text
  end


  def multy_get_from_hash(urls)
    urls.each_key do |key|
      file_name = ROOT_PATH+"/dw-sima/"+key+".html"
      if File.exists?(file_name) and !File.zero?(file_name)
        urls.delete(key)
      end
    end
    if !urls.empty?
    m = Curl::Multi.new
    m.pipeline = true
    #responses = {}
    urls.each_pair do |key, value|
      responses[value] = ""
      c = Curl::Easy.new(value) do|curl|
        curl.follow_location = true
        #curl.on_body{|d| f = File.new(ROOT_PATH+'/dw-sima/'+key+'.html', 'w') {|f| f.write(d)}}
        curl.on_body {|d| File.open(ROOT_PATH+'/dw-sima/'+key+'.html', 'a') {|f| f.write d} }
        #curl.body_str{|data| responses[value] << data; data.size }
        #curl.on_body{|data| responses[key] << data;data.size }
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

  def mysql_connect(host,user,pass)
    begin
         con = Mysql2::Client.new(:host=>host,:username=>user, :password => pass)
         rs = con.query 'SELECT VERSION()'
         rs.each{|r| puts r}

     rescue Mysql2::Error => e
         @@log.error e.error_number
         @@log.error e.sql_state

     ensure
         con.close if con
    end
  end