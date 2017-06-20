# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'wikipedia/version'
require 'date'

# rubocop:disable Metrics/BlockLength
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
  s.rubygems_version = '1.8.23'
  s.summary          = 'Ruby client for the Wikipedia API'
  s.platform         = Gem::Platform::RUBY
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.has_rdoc         = true
  s.extra_rdoc_files = ['README.textile']
  s.bindir           = 'bin'

  s.require_paths    << 'lib'
  s.rdoc_options     << '--title' << 'wikipedia-client' << '--main' << '-ri'

  s.add_development_dependency('rake', '~> 10.1')
  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('rdoc', '~> 4.0')
  s.add_development_dependency('jeweler', '~> 1.8')
  s.add_development_dependency('rubocop', '~> 0.48')

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_development_dependency('thoughtbot-shoulda', '~> 2.11', ['>= 2.11'])
    else
      s.add_dependency('thoughtbot-shoulda', ['>= 0'])
    end
  else
    s.add_dependency('thoughtbot-shoulda', ['>= 0'])
  end
end
