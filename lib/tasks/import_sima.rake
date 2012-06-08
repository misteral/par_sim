namespace :spree do
  desc "Load our suvenir and igr"
  task :import_sima  do
    #require 'my_import_products'
    ImportSima.new.perform
  end
end

