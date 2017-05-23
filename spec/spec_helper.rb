require 'rspec'

if ENV['COVERAGE'] == 'true'
  begin
    require 'simplecov'
    SimpleCov.start
  rescue LoadError
    abort 'Coverage driver not available. In order to run coverage, you must run: gem install simplecov'
  end
end

require File.dirname(__FILE__) + '/../lib/wikipedia'
