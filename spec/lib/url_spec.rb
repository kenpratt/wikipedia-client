require File.dirname(__FILE__) + '/../spec_helper'

describe Wikipedia::Url, 'like http://en.wikipedia.org/wiki/Getting_Things_Done' do
  it 'should have a title of Getting_Things_Done' do
    url = Wikipedia::Url.new('http://en.wikipedia.org/wiki/Getting_Things_Done')
    expect(url.title).to eq('Getting_Things_Done')
  end
end
