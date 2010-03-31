require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

describe Wikipedia::Page, ".sanitize wiki markup" do
  Dir[File.dirname(__FILE__) + '/../fixtures/sanitization_samples/*-raw.txt'].each do |raw_filename|
    name = raw_filename.sub(/\/(.+?)\-raw\.txt$/, '\1')
    sanitized_filename = raw_filename.sub('-raw', '-sanitized')
    it "should sanitize #{name} properly" do
      @raw = File.read(raw_filename)
      @sanitized = File.read(sanitized_filename).strip
      Wikipedia::Page.sanitize(@raw).strip.should == @sanitized
    end
  end
end
