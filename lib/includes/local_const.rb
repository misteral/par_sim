# encoding: utf-8
module ImportSima

  PROXY = 'http://10.44.33.209:842'
  #PROXY = ''
  M_HOST = "localhost"
  M_USER = "root"
  M_PASS = "fduecn"
  M_DB = "sundmart"
  provider = 'file'
  ROOT_PATH = ENV['HOME']+"/import_spree/"
  FILES_PATH = ROOT_PATH+"files-sima/"
  LOG_PATH = ROOT_PATH+"log/"
  IMAGE_PATH = ROOT_PATH+"images_sima/"
  IMAGE_PATH_ORIGINAL = IMAGE_PATH+'original/'
  IMAGE_PATH_WITH_LOGO = IMAGE_PATH+'with_logo/'
  LOGO_IMAGE = ROOT_PATH+"/logo/chaiknet_logo1.psd"
  EXPORT_FILE = "sima_export.csv"

  #проверим есть ли и создадим каталоги


  def self.create_folder(provider,path)
    if provider == "file"
      Dir.mkdir(path) unless File.exists?(path)
    end
  end

  create_folder(provider,ROOT_PATH)
  create_folder(provider,LOG_PATH)
  create_folder(provider,FILES_PATH)
  create_folder(provider,IMAGE_PATH)
  create_folder(provider,IMAGE_PATH_ORIGINAL)
  create_folder(provider,IMAGE_PATH_WITH_LOGO)


  def self.sima_image_url
    "http://st#{[1,2,3,4,5].sample.to_s}.sima-land.ru/images/photo/big/"
  end

end

