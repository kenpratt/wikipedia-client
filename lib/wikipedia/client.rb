module Wikipedia
  class Client
    # see http://en.wikipedia.org/w/api.php
    BASE_URL = ":protocol://:domain/:path?action=:action&format=json"

    attr_accessor :follow_redirects

    def initialize
      self.follow_redirects = true
    end

    # Find a wikipedia page given a hash of options
    #
    # @overload find(title, options)
    #   @param title [String] a wikipedia page title
    #   @param options [Hash] an options hash
    #   @return [Object] new page item
    def find( title, options = {} )
      title = Url.new(title).title rescue title
      page = Page.new( request_page( title, options ) )
      while follow_redirects and page.redirect?
        page = Page.new( request_page( page.redirect_title, options ) )
      end
      page
    end

    # Find a image from the API given a hash of options
    #
    # @overload find_image(title, options)
    #   @param title [String] a wikipedia page title
    #   @param options [Hash] an options hash
    #   @return [Object] a new image item
    def find_image( title, options = {} )
      title = Url.new(title).title rescue title
      Page.new( request_image( title, options ) )
    end

    # Helper function called for requesting a page by the find method
    #
    # @overload request_page(title, options)
    #   @param title [String] a wikipedia page title
    #   @param options [Hash] an options hash
    #   @return [Request] returns a request item
    # http://en.wikipedia.org/w/api.php?action=query&format=json&prop=revisions%7Clinks%7Cimages%7Ccategories&rvprop=content&titles=Flower%20(video%20game)
    def request_page( title, options = {} )
      request( {
                 :action => "query",
                 :prop => %w{ revisions links extlinks images categories coordinates templates },
                 :rvprop => "content",
                 :inprop => "url",
                 :titles => title
               }.merge( options ) )
    end

    # Helper function called for requesting an image by the find_image method
    #
    # @overload request_image(title, options)
    #   @param title [String] a wikipedia page title
    #   @param options [Hash] an options hash
    #   @return [Request] returns a request item
    # http://en.wikipedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&titles=File:Flower.png
    def request_image( title, options = {} )
      request( {
                 :action => "query",
                 :prop => "imageinfo",
                 :iiprop => "url",
                 :titles => title
               }.merge( options ) )
    end

    

    protected
      def configuration_options
        {
          :protocol => Configuration[:protocol],
          :domain   => Configuration[:domain],
          :path     => Configuration[:path]
        }
      end

      # Helper function that performs a request given configuration options
      #
      # @overload request(options)
      #   @param options [Hash] an options hash
      #   @return [Request] returns a request item
      def request( options )
        require 'open-uri'
        URI.parse( url_for( options ) ).read( "User-Agent" => "Ruby/#{RUBY_VERSION}" )
      end

      # Given an options hash, returns a URL string for the options
      #
      # @overload url_for(options)
      #   @param options [Hash] an options hash
      #   @return [String] returns a url string
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

      # Encodes value to url. Flattens if it is array
      #
      # @overload urlify_value(val)
      #   @param val [Object] 
      #   @return [String] returns a urlified value
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
