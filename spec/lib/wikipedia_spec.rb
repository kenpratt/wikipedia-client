require File.dirname(__FILE__) + '/../spec_helper'

describe Wikipedia, '.find' do
  it 'should return a Wikipedia::Page instance' do
    page = Wikipedia.find('Getting_Things_Done')
    expect(page).to be_an_instance_of(Wikipedia::Page)
  end

  it 'should return a Page with a title' do
    page = Wikipedia.find('Getting_Things_Done')
    expect(page.title).not_to be_nil
  end

  it 'should return a Page given a URL' do
    page1 = Wikipedia.find('Getting_Things_Done')

    page2 = Wikipedia.find('http://en.wikipedia.org/wiki/Getting_Things_Done')
    expect(page1.title).to eq(page2.title)
  end
end
