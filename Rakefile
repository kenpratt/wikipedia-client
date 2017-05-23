$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'rake'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task default: [:spec, :rubocop]

desc 'Test the wikipedia plugin.'
RSpec::Core::RakeTask.new(:spec)

desc 'Run rubocop'
RuboCop::RakeTask.new(:rubocop)

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort 'RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov'
  end
end

require 'rdoc/task'
require 'wikipedia/version'
Rake::RDocTask.new do |rdoc|
  version = Wikipedia::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "wikipedia-client #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
