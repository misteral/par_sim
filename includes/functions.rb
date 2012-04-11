
  def open_or_download(url,proxy)
    file_name = ROOT_PATH+"/dw-sima/"+url[:name]+".html"
    if File.exists?(file_name) and !File.zero?(file_name)
      text = open(file_name) { |f| f.read }
    else
      fr = File.new(file_name, "w+")
      text = open(url['url'], :proxy => proxy).read
      File.open(file_name, 'w') {|f| f.write(text) }
    end

    text
  end


  def multy_get_from_hash(urls)
    m = Curl::Multi.new
    responses = {}
    urls.each_pair do |key, value|
      c = Curl::Easy.new(value) do|curl|
        curl.follow_location = true
        curl.on_body{
              |d| f = File.new(key+'.html', 'w') {|f| f.write d}
            }
      end
      m.add(c)
    end
    m.perform do
      puts "idling... can do some work here"
    end

    true

  end