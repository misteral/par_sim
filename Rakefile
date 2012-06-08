require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
#require 'spree/core/testing_support/common_rake'

RSpec::Core::RakeTask.new

task :default => [:spec]

spec = eval(File.read('spree_import_sima.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end

desc "Load our suvenir and igr"
  task :import_sima  do
    #require 'my_import_products'
    ImportSima.new.perform
end

