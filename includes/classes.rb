class MyMySQL
   #attr_accessor :host, :user, :password
  def initialize (host,user,pass, db)
    begin
      @@con = Mysql2::Client.new(:host=>host,:username=>user, :password => pass, :database=> db)
    rescue Mysql2::Error => e
      $log.error e.error_number
      $log.error e.sql_state
    end
  end
  def insert_al(options={})
    options[:product_status] ||= 2
    options[:product_paernt_id] ||= 0
    options[:product_is_group] ||= true
    options[:product_ed] ||= ""
    options[:product_min] ||= ""
    options[:product_price] ||= 0
    options[:product_sku] ||= ""
    options[:product_desc] ||= ""

    #begin

    q = "insert into jos_al_import (
              product_name,
              product_url,
              product_status,
              product_vendor,
              product_parent_id,
              product_isgroup,
              product_ed,
              product_min,
              product_price,
              product_sku,
              product_desc
              )

              values ('#{options[:product_name]}',
                      '#{options[:product_url]}',
                      #{options[:product_status].to_i},
                      1,
                      #{options[:product_parent_id].to_i},
                      #{options[:product_is_group]},
                      '#{options[:product_ed]}',
                      '#{options[:product_min]}',
                      #{options[:product_price]},
                      '#{options[:product_sku]}',
                      '#{options[:product_desc]}'
    );"
      @@con.query q
#:TODO Сделать exeptions на запросы а то падает в хлам
    #rescue @@con::Error => e
    #  $log.error e.error_number
    #  $og.error e.sql_state
    #end
  end
end #end class MySQL
