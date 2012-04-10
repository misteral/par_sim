require 'open-uri'
require 'nokogiri'
coo=0
doc = Nokogiri::HTML(open("http://www.sima-land.ru/catalog.html"))
start = doc.xpath('//div[@class="text-catalog"]')[0]
start.css('span div h3 a').each do |el1|
  url = el1['href']
  tex = el1.text
  coo=coo+1
  puts coo.to_s+": "+tex+'-'+url
end

