module Wikipedia
  class Client
    # see http://en.wikipedia.org/w/api.php
    BASE_URL = "http://:domain/:path?action=:action&format=json"

    # Sample API queries:
    # http://en.wikipedia.org/w/api.php?action=query&format=xml&prop=revisions%7Clinks%7Cimages%7Ccategories&rvprop=content&titles=Flower_%28video_game%29
    # http://en.wikipedia.org/w/api.php?action=query&format=xml&prop=imageinfo&iiprop=url&titles=File:Flower.png

    attr_accessor :follow_redirects

    def initialize
      self.follow_redirects = true
    end

    def find( title )
      title = Url.new(title).title rescue title
      page = Page.new( request_page( title ) )
      while follow_redirects and page.redirect?
        page = Page.new( request_page( page.redirect_title ))
      end
      page
    end

    def request_page( title, options = {} )
      request( {
                 :action => "query",
                 :prop => "revisions",
                 :rvprop => "content",
                 :titles => title
               }.merge( options ) )
    end

    def request( options )
      require 'open-uri'
      URI.parse( url_for( options ) ).read( "User-Agent" => "Ruby/#{RUBY_VERSION}" )
    end

    protected
      def configuration_options
        {
          :domain => Configuration[:domain],
          :path   => Configuration[:path]
        }
      end

      def url_for( options )
        url = BASE_URL.dup
        options = configuration_options.merge( options )
        options.each do |key, val|
          value = urlify_value( val )
          if url.include?( ":#{key}" )
            url.sub! ":#{key}", value
          else
            url << "&#{key}=#{value}"
          end
        end
        URI.encode( url )
      end

      def urlify_value( val )
        case val
        when Array
          val.flatten.join( '|' )
        else
          val
        end
      end
  end
end
