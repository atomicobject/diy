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

if File.exists?("../tools/")
  load "../tools/tasks/homepage.rake"
  load "../tools/tasks/release_tagging.rake"
  ReleaseTagging.new do |t|
    t.package = "diy"
    t.version = DIY::VERSION
  end

  desc "Release package to Rubyforge, tag the release in svn, and publish documentation"
  task :release_full => [ :release, :tag_release, :publish_docs ] 
end
