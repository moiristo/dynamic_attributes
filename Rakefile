require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dynamic_attributes"
    gem.summary = %Q{dynamic_attributes is a gem that lets you dynamically specify attributes on ActiveRecord models, which will be serialized and
deserialized to a given text column.}
    gem.description = %Q{dynamic_attributes is a gem that lets you dynamically specify attributes on ActiveRecord models, which will be serialized and
deserialized to a given text column. Dynamic attributes can be defined by simply setting an attribute or by passing them on create or update.}
    gem.email = "r.j.delange@nedforce.nl"
    gem.homepage = "http://github.com/moiristo/dynamic_attributes"
    gem.authors = ["Reinier de Lange"]
    gem.files = [
      "init.rb",
      ".document",
      ".gitignore",
      "LICENSE",
      "README.rdoc",
      "Rakefile",
      "VERSION",
      "lib/dynamic_attributes.rb"
    ]
    gem.test_files = [
      "test/helper.rb",
      "test/test_dynamic_attributes.rb",
      "test/database.yml",
      "test/schema.rb"      
    ]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies
task :default => :test

