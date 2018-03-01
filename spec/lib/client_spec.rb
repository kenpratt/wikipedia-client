require File.dirname(__FILE__) + '/../spec_helper'
require 'json'

# rubocop:disable Metrics/BlockLength
describe Wikipedia::Client, '.find page (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON.parse(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    expect(@client).to receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should execute a request for the page' do
    @client.find('Edsger_Dijkstra')
  end

  it 'should return a page object' do
    expect(@client.find('Edsger_Dijkstra')).to be_an_instance_of(Wikipedia::Page)
  end

  it 'should return a page with the correct content' do
    @page = @client.find('Edsger_Dijkstra')
    expect(@page.content).to eq(@edsger_content)
  end

  it 'should return a page with a title of Edsger W. Dijkstra' do
    @page = @client.find('Edsger_Dijkstra')
    expect(@page.title).to eq('Edsger W. Dijkstra')
  end

  it 'should return a page with the correct URL' do
    @page = @client.find('Edsger_Dijkstra')
    expect(@page.fullurl).to eq('http://en.wikipedia.org/wiki/Edsger_W._Dijkstra')
  end

  it 'should return a page with the correct plain text extract' do
    @page = @client.find('Edsger_Dijkstra')
    expect(@page.text).to start_with 'Edsger Wybe Dijkstra (Dutch pronunciation: '
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
      expect(@page.categories).to include(category)
    end
  end

  it 'should return a page with links' do
    @page = @client.find('Edsger_Dijkstra')
    [
      'ALGOL', 'Alan Kay', 'ALGOL 60', 'Agile software development', 'ACM Turing Award',
      'Algorithm', 'Adi Shamir', 'Alan Perlis', 'Allen Newell', 'Adriaan van Wijngaarden'
    ].each do |link|
      expect(@page.links).to include(link)
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
      expect(@page.images).to include(file)
    end
  end
end

describe Wikipedia::Client, '.find page with one section (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    dir_name = File.dirname(__FILE__)
    @edsger_dijkstra = File.read(dir_name + '/../fixtures/Edsger_Dijkstra_section_0.json')
    @edsger_content = File.read(dir_name + '/../fixtures/sanitization_samples/Edsger_W_Dijkstra-sanitized.txt').strip
    expect(@client).to receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should have the correct sanitized intro' do
    @page = @client.find('Edsger_Dijkstra', rvsection: 0)
    expect(@page.sanitized_content).to eq(@edsger_content)
  end
end

describe Wikipedia::Client, '.find page with special characters in title' do
  before(:each) do
    @client = Wikipedia::Client.new
  end

  it 'should properly escape all special characters' do
    @page = @client.find('A +&%=?:/ B')
    expect(@page.title).to eq('A +&%=?:/ B')
    expect(@page.fullurl).to eq('https://en.wikipedia.org/wiki/A_%2B%26%25%3D%3F:/_B')
  end

  it 'should handle pluses in article titles' do
    @page = @client.find('C++')
    expect(@page.title).to eq('C++')
    expect(@page.fullurl).to eq('https://en.wikipedia.org/wiki/C%2B%2B')
  end
end

describe Wikipedia::Client, '.find image (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/File_Edsger_Wybe_Dijkstra_jpg.json')
    expect(@client).to receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should execute a request for the image' do
    @client.find_image('File:Edsger Wybe Dijkstra.jpg')
  end

  it 'should return a page object' do
    expect(@client.find_image('File:Edsger Wybe Dijkstra.jpg')).to be_an_instance_of(Wikipedia::Page)
  end

  it 'should return a page with a title of File:Edsger Wybe Dijkstra.jpg' do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    expect(@page.title).to eq('File:Edsger Wybe Dijkstra.jpg')
  end

  it 'should return a page with an image url' do
    @page = @client.find_image('File:Edsger Wybe Dijkstra.jpg')
    expect(@page.image_url).to eq('http://upload.wikimedia.org/wikipedia/commons/d/d9/Edsger_Wybe_Dijkstra.jpg')
  end
end

describe Wikipedia::Client, '.find page (Edsger_Dijkstra)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @client.follow_redirects = false
  end

  it 'should get a redirect when trying Edsger Dijkstra' do
    @page = @client.find('Edsger Dijkstra')
    expect(@page).to be_redirect
  end

  it 'should get a final page when follow_redirects is true' do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    expect(@page).not_to be_redirect
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
      expect(@page.image_urls).to include('https://upload.wikimedia.org/wikipedia' + image)
    end
  end

  it 'should collect the image thumbnail urls with default width' do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    [
      '/en/thumb/4/4a/Commons-logo.svg/200px-Commons-logo.svg.png',
      '/en/thumb/4/48/Folder_Hexagonal_Icon.svg/200px-Folder_Hexagonal_Icon.svg.png',
      '/commons/thumb/5/57/Dijkstra_Animation.gif/200px-Dijkstra_Animation.gif',
      '/commons/thumb/c/c9/Edsger_Dijkstra_1994.jpg/200px-Edsger_Dijkstra_1994.jpg',
      '/commons/thumb/d/d9/Edsger_Wybe_Dijkstra.jpg/200px-Edsger_Wybe_Dijkstra.jpg',
      '/commons/thumb/0/00/Complex-adaptive-system.jpg/200px-Complex-adaptive-system.jpg',
      '/en/thumb/4/4d/Centrum-wiskunde-informatica-logo.png/200px-Centrum-wiskunde-informatica-logo.png'
    ].each do |image|
      expect(@page.image_thumburls).to include('https://upload.wikimedia.org/wikipedia' + image)
    end
  end

  it 'should collect the image thumbnail urls with specified width' do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    [
      '/en/thumb/4/4a/Commons-logo.svg/100px-Commons-logo.svg.png',
      '/en/thumb/4/48/Folder_Hexagonal_Icon.svg/100px-Folder_Hexagonal_Icon.svg.png',
      '/commons/thumb/5/57/Dijkstra_Animation.gif/100px-Dijkstra_Animation.gif',
      '/commons/thumb/c/c9/Edsger_Dijkstra_1994.jpg/100px-Edsger_Dijkstra_1994.jpg',
      '/commons/thumb/d/d9/Edsger_Wybe_Dijkstra.jpg/100px-Edsger_Wybe_Dijkstra.jpg',
      '/commons/thumb/0/00/Complex-adaptive-system.jpg/100px-Complex-adaptive-system.jpg',
      '/en/thumb/4/4d/Centrum-wiskunde-informatica-logo.png/100px-Centrum-wiskunde-informatica-logo.png'
    ].each do |image|
      expect(@page.image_thumburls(100)).to include('https://upload.wikimedia.org/wikipedia' + image)
    end
  end

  it 'should collect the main image thumburl' do
    @client.follow_redirects = true
    @page = @client.find('Edsger Dijkstra')
    image = '/commons/thumb/d/d9/Edsger_Wybe_Dijkstra.jpg/150px-Edsger_Wybe_Dijkstra.jpg'
    expect(@page.main_image_thumburl).to include('https://upload.wikimedia.org/wikipedia' + image)
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
    expect(@page).to be_redirect
  end

  it 'should get a final page when follow_redirects is true' do
    @client.follow_redirects = true
    @page = @client.find('Rails')
    expect(@page).not_to be_redirect
  end
end

describe Wikipedia::Client, '.find random page' do
  before(:each) do
    @client = Wikipedia::Client.new
  end

  it 'should get random pages' do
    @page1 = @client.find_random.title
    @page2 = @client.find_random.title
    expect(@page1).not_to eq(@page2)
  end
end

describe Wikipedia::Client, 'page.summary (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @edsger_dijkstra = File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_Dijkstra.json')
    @edsger_content  = JSON.parse(File.read(File.dirname(__FILE__) + '/../fixtures/Edsger_content.txt'))['content']
    expect(@client).to receive(:request).and_return(@edsger_dijkstra)
  end

  it 'should return only the summary' do
    @page = @client.find('Edsger_Dijkstra')
    expect(@page.summary).to eq('Edsger Wybe Dijkstra (Dutch pronunciation: [ˈɛtsxər ˈʋibə ˈdɛikstra] ( );'\
    ' 11 May 1930 – 6 August 2002) was a Dutch computer scientist. He received the 1972 Turing Award for fundamental'\
    ' contributions to developing programming languages, and was the Schlumberger Centennial Chair of Computer'\
    " Sciences at The University of Texas at Austin from 1984 until 2000.\nShortly before his death in 2002, he"\
    ' received the ACM PODC Influential Paper Award in distributed computing for his work on self-stabilization of'\
    ' program computation. This annual award was renamed the Dijkstra Prize the following year, in his honor.')
  end
end

describe Wikipedia::Client, '.find page (mocked)' do
  before(:each) do
    @client = Wikipedia::Client.new
    @sealand_dynasty = File.read(File.dirname(__FILE__) + '/../fixtures/Sealand_Dynasty.json')
    expect(@client).to receive(:request).and_return(@sealand_dynasty)
  end

  it 'should return nil' do
    @page = @client.find('Sealand_Dynasty')
    expect(@page.image_urls).to eq(nil)
  end
end
