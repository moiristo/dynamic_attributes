require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dynamic_attributes"
    gem.summary = %Q{Dynamic attributes is a gem that lets you dynamically specify attributes on ActiveRecord models, which will be serialized and
deserialized to a given text column.}
    gem.description = %Q{Dynamic attributes is a gem that lets you dynamically specify attributes on ActiveRecord models, which will be serialized and
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
  #Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dynamic_attributes #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
