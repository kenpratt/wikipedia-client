require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

describe Wikipedia::Client, ".find (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON::load(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end
  
  it "should execute a request for the page" do
    @client.find('Edsger_Dijkstra')
  end
  
  it "should return a page object" do
    @client.find('Edsger_Dijkstra').should be_an_instance_of(Wikipedia::Page)
  end
  
  it "should return a page with the correct content" do
    @page = @client.find('Edsger_Dijkstra')
    @page.content.should == @edsger_content
  end
  
  it "should return a page with a title of Edsger W. Dijkstra" do
    @page = @client.find('Edsger_Dijkstra')
    @page.title.should == 'Edsger W. Dijkstra'
  end
end

describe Wikipedia::Client, ".find (Edsger_Dijkstra)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @client.follow_redirects = false
  end
  
  it "should get a redirect when trying Edsger Dijkstra" do
    @page = @client.find('Edsger Dijkstra')
    @page.should be_redirect
  end
  
  it "should get a final page when follow_redirects is true" do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    @page.should_not be_redirect
  end
end