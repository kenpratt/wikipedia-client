require 'rake'
require 'rake/rdoctask'

desc 'Default: run specifications.'
task :default => :spec

desc 'Test the wikipedia plugin.'
task :spec do
  spec_path = File.expand_path(File.dirname(__FILE__) + '/spec/**/*.rb')
  system("spec -cfs #{spec_path}")
end

desc 'Generate documentation for the wikipedia plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Wikipedia'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
