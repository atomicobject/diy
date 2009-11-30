require 'rubygems'
require 'jeweler'

$: << "lib"
require 'diy.rb'

task :default => [ :test ]

Jeweler::Tasks.new do |gemspec|
  gemspec.name = 'diy'
  gemspec.version = DIY::VERSION
  gemspec.summary = 'Constructor-based dependency injection container using YAML input.'
  gemspec.description = 'Constructor-based dependency injection container using YAML input.'
  gemspec.homepage = 'http://atomicobject.github.com'
  gemspec.authors = 'Atomic Object'
  gemspec.email = 'dev@atomicobject.com'
  gemspec.test_files = FileList['test/*_test.rb']
  gemspec.add_dependency 'constructor', '>= 1.0.0'
end
