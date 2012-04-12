
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
    m = Curl::Multi.new
    responses = {}
    urls.each_pair do |key, value|
      responses[value] = ""
      c = Curl::Easy.new(value) do|curl|
        curl.follow_location = true
        curl.pipeline = true
        curl.body_str{
              |d| f = File.new(ROOT_PATH+'/dw-sima/'+key+'.html', 'w') {|f| f.write(d)}
            }
        curl.on_body{|data| responses[value] << data; data.size }
      end
      m.add(c)
    end
    m.perform do
      puts "idling... can do some work here"
    end

    urls.each do|url|
       puts responses[url]
     end

    true

  end