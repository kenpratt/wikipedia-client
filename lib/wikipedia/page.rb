module Wikipedia
  class Page
    def initialize(json)
      require 'json'
      @data = JSON::load(json)
    end
    
    def content
      @data['query']['pages'].values.first['revisions'].first.values.first
    end
    
    def redirect?
      content.match(/\#REDIRECT\s+\[\[(.*?)\]\]/)
    end
    
    def redirect_title
      if matches = redirect?
        matches[1]
      end
    end
    
    def title
      @data['query']['pages'].values.first['title']
    end
  end

end