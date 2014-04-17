# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wikipedia/version"

spec = Gem::Specification.new do |s|
  s.name    = "wikipedia-client"
  s.version = Wikipedia::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.license          = 'MIT'
  s.authors          = ["Cyril David", "Ken Pratt", "Mike Haugland"]
  s.date             = "2014-04-16"
  s.description      = "Ruby client for the Wikipedia API"
  s.email            = "mike.haugland@gmail.com"

  s.homepage         = "http://github.com/mhaugland/wikipedia-client"
  s.rubygems_version = "1.8.23"
  s.summary          = "Ruby client for the Wikipedia API"
  s.platform         = Gem::Platform::RUBY
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.has_rdoc         = true
  s.extra_rdoc_files = ['README.textile']
  s.bindir           = 'bin'

  s.require_paths    << 'lib'
  s.rdoc_options     << '--title' << 'wikipedia-client' << '--main' << '-ri'

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('jeweler')

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end
