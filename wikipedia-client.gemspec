# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'wikipedia/version'
require 'date'

Gem::Specification.new do |s|
  s.name    = 'wikipedia-client'
  s.version = Wikipedia::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=

  s.license          = 'MIT'
  s.authors          = ['Cyril David', 'Ken Pratt', 'Mike Haugland',
                        'Aishwarya Subramanian', 'Pietro Menna', 'Sophie Rapoport']
  s.date             = Date.today.to_s
  s.description      = 'Ruby client for the Wikipedia API'
  s.email            = 'ken@kenpratt.net'

  s.homepage         = 'http://github.com/kenpratt/wikipedia-client'
  s.summary          = 'Ruby client for the Wikipedia API'
  s.platform         = Gem::Platform::RUBY
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.extra_rdoc_files = ['README.md']
  s.bindir           = 'bin'

  s.require_paths    << 'lib'
  s.rdoc_options     << '--title' << 'wikipedia-client' << '--main' << '-ri'

  s.add_runtime_dependency 'addressable', '~> 2.7'
end
