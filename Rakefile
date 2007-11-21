require 'rubygems'
require 'hoe'
require './lib/diy.rb'

task :default => [ :test ]

Hoe.new('diy', DIY::VERSION) do |p|
  p.rubyforge_name = 'atomicobjectrb'
  p.author = 'Atomic Object'
  p.email = 'dev@atomicobject.com'
  p.summary = 'Constructor-based dependency injection container using YAML input.'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.test_globs = 'test/*_test.rb'
  p.extra_deps << ['constructor', '>= 1.0.0']
end
