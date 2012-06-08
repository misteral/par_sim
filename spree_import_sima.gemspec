# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_import_sima'
  s.version     = '1.1.1'
  s.summary     = 'Импорт Симы'
  s.description = 'Импорт Симы'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = '--al--'
  s.email     = 'mister-al@ya.ru'
  s.homepage  = 'http://www.spreecommerce.com'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.1.1'
  s.add_dependency('nokogiri','>= 1.5.2')
  s.add_dependency('rmagick','>= 2.13.1')
  s.add_dependency('curb','>= 0.8.0')
  s.add_dependency('mysql2','>= 0.3.11')

  #s.add_development_dependency 'capybara', '1.0.1'
  #s.add_development_dependency 'factory_girl', '~> 2.6.4'
  #s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  #s.add_development_dependency 'sqlite3'
end

