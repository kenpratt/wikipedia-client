$:.push File.expand_path("../lib", __FILE__)
require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


desc 'Test the wikipedia plugin.'
task :spec do
  spec_path = File.expand_path(File.dirname(__FILE__) + '/spec/**/*.rb')
  system("rspec -cfs #{spec_path}")
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

task :default => :spec

require 'rdoc/task'
require "wikipedia/version"
Rake::RDocTask.new do |rdoc|
  version = Wikipedia::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "wikipedia-client #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
