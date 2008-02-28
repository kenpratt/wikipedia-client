module Wikipedia
  class Url
    def initialize(wiki_url)
      @wiki_url = wiki_url
    end
    
    def title
      return @title if @title
      
      uri     = URI.parse( @wiki_url )
      @title  = uri.path.split('/').last
    end
  end
end