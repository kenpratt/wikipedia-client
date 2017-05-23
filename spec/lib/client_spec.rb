require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

# rubocop:disable Metrics/BlockLength
describe Wikipedia::Client, '.find page (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON.parse(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should execute a request for the page' do
    @client.find('Edsger_Dijkstra')
  end

  it 'should return a page object' do
    @client.find('Edsger_Dijkstra').should be_an_instance_of(Wikipedia::Page)
  end

  it 'should return a page with the correct content' do
    @page = @client.find('Edsger_Dijkstra')
    @page.content.should == @edsger_content
  end

  it 'should return a page with a title of Edsger W. Dijkstra' do
    @page = @client.find('Edsger_Dijkstra')
    @page.title.should == 'Edsger W. Dijkstra'
  end

  it 'should return a page with the correct URL' do
    @page = @client.find('Edsger_Dijkstra')
    @page.fullurl.should == 'http://en.wikipedia.org/wiki/Edsger_W._Dijkstra'
  end

  it 'should return a page with the correct plain text extract' do
    @page = @client.find('Edsger_Dijkstra')
    @page.text.should start_with 'Edsger Wybe Dijkstra (Dutch pronunciation: '
  end

  it 'should return a page with categories' do
    @page = @client.find('Edsger_Dijkstra')
    [
      'Category:1930 births', 'Category:Fellows of the Association for Computing Machinery',
      'Category:2002 deaths', 'Category:Articles with close paraphrasing from April 2009',
      'Category:Computer pioneers', 'Category:Eindhoven University of Technology faculty',
      'Category:Dutch physicists', 'Category:Articles needing cleanup from April 2009',
      'Category:All pages needing cleanup', 'Category:Dutch computer scientists'
    ].each do |category|
      @page.categories.should include(category)
    end
  end

  it 'should return a page with links' do
    @page = @client.find('Edsger_Dijkstra')
    [
      'ALGOL', 'Alan Kay', 'ALGOL 60', 'Agile software development', 'ACM Turing Award',
      'Algorithm', 'Adi Shamir', 'Alan Perlis', 'Allen Newell', 'Adriaan van Wijngaarden'
    ].each do |link|
      @page.links.should include(link)
    end
  end

  it 'should return a page with images' do
    @page = @client.find('Edsger_Dijkstra')
    [
      'File:Dijkstra.ogg',
      'File:Speaker Icon.svg',
      'File:Wikiquote-logo-en.svg',
      'File:Copyright-problem.svg',
      'File:Edsger Wybe Dijkstra.jpg'
    ].each do |file|
      @page.images.should include(file)
    end
  end
end

describe Wikipedia::Client, '.find page with one section (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    dir_name = File.dirname(__FILE__)
    @edsger_dijkstra = File.read(dir_name + '/../fixtures/Edsger_Dijkstra_section_0.json')
    @edsger_content = File.read(dir_name + '/../fixtures/sanitization_samples/Edsger_W_Dijkstra-sanitized.txt').strip
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should have the correct sanitized intro' do
    @page = @client.find('Edsger_Dijkstra', rvsection: 0)
    @page.sanitized_content.should == @edsger_content
  end
end

describe Wikipedia::Client, '.find image (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/File_Edsger_Wybe_Dijkstra_jpg.json')
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should execute a request for the image' do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg')
  end

  it 'should return a page object' do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg').should be_an_instance_of(Wikipedia::Page)
  end

  it 'should return a page with a title of File:Edsger Wybe Dijkstra.jpg' do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    @page.title.should == 'File:Edsger Wybe Dijkstra.jpg'
  end

  it 'should return a page with an image url' do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    @page.image_url.should == 'http://upload.wikimedia.org/wikipedia/commons/d/d9/Edsger_Wybe_Dijkstra.jpg'
  end
end

describe Wikipedia::Client, '.find page (Edsger_Dijkstra)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @client.follow_redirects = false
  end

  it 'should get a redirect when trying Edsger Dijkstra' do
    @page = @client.find('Edsger Dijkstra')
    @page.should be_redirect
  end

  it 'should get a final page when follow_redirects is true' do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    @page.should_not be_redirect
  end

  it 'should collect the image urls' do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    [
      '/en/4/4a/Commons-logo.svg',
      '/en/4/48/Folder_Hexagonal_Icon.svg',
      '/commons/5/57/Dijkstra_Animation.gif',
      '/commons/c/c9/Edsger_Dijkstra_1994.jpg',
      '/commons/d/d9/Edsger_Wybe_Dijkstra.jpg',
      '/commons/0/00/Complex-adaptive-system.jpg',
      '/en/4/4d/Centrum-wiskunde-informatica-logo.png',
      '/commons/7/7b/An_illustration_of_the_dining_philosophers_problem.png',
      '/commons/3/37/Detail_of_a_1Kb_ferrite_core_RAM-module_of_an_1960s_Electrologica_X1_computer.jpg'
    ].each do |image|
      @page.image_urls.should include('https://upload.wikimedia.org/wikipedia' + image)
    end
  end
end

describe Wikipedia::Client, '.find page (Rails) at jp' do
  before(:each) do
    Wikipedia.configure { domain 'ja.wikipedia.org' }
    @client = Wikipedia::Client.new
    @client.follow_redirects = false
  end

  it 'should get a redirect when trying Rails' do
    @page = @client.find('Rails')
    @page.should be_redirect
  end

  it 'should get a final page when follow_redirects is true' do
    @client.follow_redirects = true
    @page = @client.find('Rails')
    @page.should_not be_redirect
  end
end

describe Wikipedia::Client, '.find random page' do
  before(:each) do
    @client = Wikipedia::Client.new
  end

  it 'should get random pages' do
    @page1 = @client.find_random.title
    @page2 = @client.find_random.title
    @page1.should_not == @page2
  end
end

describe Wikipedia::Client, 'page.summary (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON.parse(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    @client.should_receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should return only the summary' do
    @page = @client.find('Edsger_Dijkstra')
    @page.summary.should == 'Edsger Wybe Dijkstra (Dutch pronunciation: [ˈɛtsxər ˈʋibə ˈdɛikstra] ( );'\
    ' 11 May 1930 – 6 August 2002) was a Dutch computer scientist. He received the 1972 Turing Award for fundamental'\
    ' contributions to developing programming languages, and was the Schlumberger Centennial Chair of Computer'\
    " Sciences at The University of Texas at Austin from 1984 until 2000.\nShortly before his death in 2002, he"\
    ' received the ACM PODC Influential Paper Award in distributed computing for his work on self-stabilization of'\
    ' program computation. This annual award was renamed the Dijkstra Prize the following year, in his honor.'
  end
end
