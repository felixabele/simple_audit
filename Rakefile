require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the simple_audit plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the simple_audit plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleAudit'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

#
# Gemify
#
begin
  require 'jeweler'
  
  gem_files = FileList[
    '[a-zA-Z]*',
    'lib/**/*',
    'rails/**/*',
    'tasks/**/*',
    'test/**/*'
  ]
  
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "simple_audit"
    gemspec.summary = "Simple auditing solution for ActiveRecord models"
    #gemspec.description = ""
    gemspec.email = "gabriel.tarnovan@cubus.ro"
    gemspec.homepage = "http://github.com/gtarnovan/simple_audit"
    gemspec.authors = ["Gabriel Tarnovan"]
    gemspec.version = "0.0.1"
    gemspec.files = gem_files.to_a
    
    gemspec.rubyforge_project = 'simple_audit'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end