require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

describe Wikipedia::Client, ".find page (mocked)" do
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

  it "should return a page with categories" do
    @page = @client.find('Edsger_Dijkstra')
    @page.categories.should == ["Category:1930 births", "Category:2002 deaths", "Category:All pages needing cleanup", "Category:Articles needing cleanup from April 2009", "Category:Articles with close paraphrasing from April 2009", "Category:Computer pioneers", "Category:Dutch computer scientists", "Category:Dutch physicists", "Category:Eindhoven University of Technology faculty", "Category:Fellows of the Association for Computing Machinery"]
  end

  it "should return a page with links" do
    @page = @client.find('Edsger_Dijkstra')
    @page.links.should == ["ACM Turing Award", "ALGOL", "ALGOL 60", "Adi Shamir", "Adriaan van Wijngaarden", "Agile software development", "Alan Kay", "Alan Perlis", "Algorithm", "Allen Newell"]
  end

  it "should return a page with images" do
    @page = @client.find('Edsger_Dijkstra')
    @page.images.should == ["File:Copyright-problem.svg", "File:Dijkstra.ogg", "File:Edsger Wybe Dijkstra.jpg", "File:Speaker Icon.svg", "File:Wikiquote-logo-en.svg"]
  end
end

describe Wikipedia::Client, ".find page with one section (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra_section_0.json')
    @edsger_content = File.read(File.dirname(__FILE__) + '/../fixtures/sanitization_samples/Edsger_W_Dijkstra-sanitized.txt').strip
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it "should have the correct sanitized intro" do
    @page = @client.find('Edsger_Dijkstra', :rvsection => 0)
    @page.sanitized_content.should == @edsger_content
  end
end

describe Wikipedia::Client, ".find image (mocked)" do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/File_Edsger_Wybe_Dijkstra_jpg.json')
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it "should execute a request for the image" do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg')
  end

  it "should return a page object" do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg').should be_an_instance_of(Wikipedia::Page)
  end

  it "should return a page with a title of File:Edsger Wybe Dijkstra.jpg" do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    @page.title.should == 'File:Edsger Wybe Dijkstra.jpg'
  end

  it "should return a page with an image url" do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    @page.image_url.should == "http://upload.wikimedia.org/wikipedia/commons/d/d9/Edsger_Wybe_Dijkstra.jpg"
  end
end

describe Wikipedia::Client, ".find page (Edsger_Dijkstra)" do
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

  it "should collect the image urls" do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    @page.image_urls.should == ["http://upload.wikimedia.org/wikipedia/commons/d/d9/Edsger_Wybe_Dijkstra.jpg"]
  end
end
