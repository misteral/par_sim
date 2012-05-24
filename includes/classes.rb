class MyMySQL
   #attr_accessor :host, :user, :password
  def initialize (host,user,pass, db)
    begin
      @@con = Mysql2::Client.new(:host=>host,:username=>user, :password => pass, :database=> db)
      q="create table sundmart.jos_al_import IF NOT EXIST(
        product_id int not null,
        product_parent_id int not null default 0,
        product_sku varchar(64),
        product_desc text(65535),
        product_full_image varchar(255),
        product_url varchar(255),
        product_name varchar(100),
        product_vendor varchar(100),
        product_isgroup bit not null default 0,
        product_status smallint,
        product_date_add datetime,
        product_ed varchar(20),
        product_min varchar(20),
        product_ost varchar(50),
        product_price float(12, 0),
        product_margin float(12, 0) default 1.8,
        tip_tov int,
        category varchar(255),
        package int,
        primary key (product_id)
      );
      create index idx_product_product_id on sundmart.jos_al_import (product_id);
      create index idx_product_sku on sundmart.jos_al_import (product_sku);
      create index idx_product_name on sundmart.jos_al_import (product_name);
      "
      @@con.query q
      q= "truncate jos_al_import"
      @@con.query q
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
    options[:product_margin] ||= 1.8
    options[:tip_tov] ||= 0
    options[:product_name] = @@con.escape(options[:product_name])

    #перевернем sku

    options[:product_sku] = swap_sku(options[:product_sku]) if options[:product_sku]


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
              product_desc,
              product_margin,
              product_ost,
              product_full_image,
              tip_tov,
              package
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
                      '#{options[:product_desc]}',
                      #{options[:product_margin]},
                      '#{options[:product_ost]}',
                      '#{options[:product_full_image]}',
                      #{options[:tip_tov]},
                      #{options[:package]}
    );"
    begin
    @@con.query q
    q2 = "select product_id from jos_al_import order by product_id DESC limit 1;"
    pr_id = ""
    result = @@con.query q2
    result.each {|res| pr_id = res['product_id']}

    pr_id
#:TODO Сделать exeptions на запросы а то падает в хлам
    rescue Mysql2::Error => e
    puts  "Mysql error number - "+e.error_number.to_s
    puts  e.sql_state
    puts  e
    #  $log.error e.error_number
    #  $og.error e.sql_state
    end
  end
end #end class MySQL

