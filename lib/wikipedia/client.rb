module Wikipedia
  class Client
    # see http://en.wikipedia.org/w/api.php
    BASE_URL = "http://:domain/:path?action=:action&format=json"

    attr_accessor :follow_redirects

    def initialize
      self.follow_redirects = true
    end

    def find( title, options = {} )
      title = Url.new(title).title rescue title
      page = Page.new( request_page( title, options ) )
      while follow_redirects and page.redirect?
        page = Page.new( request_page( page.redirect_title, options ))
      end
      page
    end

    def find_image( title, options = {} )
      title = Url.new(title).title rescue title
      Page.new( request_image( title, options ) )
    end

    # http://en.wikipedia.org/w/api.php?action=query&format=json&prop=revisions%7Clinks%7Cimages%7Ccategories&rvprop=content&titles=Flower%20(video%20game)
    def request_page( title, options = {} )
      request( {
                 :action => "query",
                 :prop => %w{ revisions links images categories },
                 :rvprop => "content",
                 :titles => title
               }.merge( options ) )
    end

    # http://en.wikipedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&titles=File:Flower.png
    def request_image( title, options = {} )
      request( {
                 :action => "query",
                 :prop => "imageinfo",
                 :iiprop => "url",
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
        url
      end

      def urlify_value( val )
        case val
        when Array
          encode( val.flatten.join( '|' ) )
        else
          encode( val )
        end
      end

      def encode( val )
        case val
        when String
          URI.encode( val ).gsub( '&', '%26' )
        else
          val
        end
      end
  end
end
