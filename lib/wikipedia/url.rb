require 'uri'
require 'addressable'

module Wikipedia
  class Url
    def initialize(wiki_url)
      @wiki_url = wiki_url
    end

    def title
      return @title if @title

      uri     = URI.parse( @wiki_url )
      @title  = Addressable::URI.unencode( uri.path.sub(/\/wiki\//, '') )
    end
  end
end
