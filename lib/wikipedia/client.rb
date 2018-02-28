module Wikipedia
  class Client
    # see http://en.wikipedia.org/w/api.php
    BASE_URL = ':protocol://:domain/:path?action=:action&format=json'.freeze

    attr_accessor :follow_redirects

    def initialize
      self.follow_redirects = true
    end

    def find( title, options = {} )
      title = Url.new(title).title rescue title
      page = Page.new( request_page( title, options ) )
      while follow_redirects && page.redirect?
        page = Page.new( request_page( page.redirect_title, options ) )
      end
      page
    end

    def find_image( title, options = {} )
      title = Url.new(title).title rescue title
      Page.new( request_image( title, options ) )
    end

    def find_random( options = {} )
      require 'json'
      data = JSON.parse( request_random( options ) )
      title = data['query']['pages'].values[0]['title']
      find( title, options )
    end

    # http://en.wikipedia.org/w/api.php?action=query&format=json&prop=revisions%7Clinks%7Cimages%7Ccategories&rvprop=content&titles=Flower%20(video%20game)
    def request_page( title, options = {} )
      request( {
        action: 'query',
        prop: %w[info revisions links extlinks images categories coordinates templates extracts pageimages],
        rvprop: 'content',
        inprop: 'url',
        pithumbsize: 200,
        explaintext: '',
        titles: title
      }.merge( options ) )
    end

    # http://en.wikipedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&iiurlwidth=200&titles=File:Albert%20Einstein%20Head.jpg
    def request_image( title, options = {} )
      request( {
        action: 'query',
        prop: 'imageinfo',
        iiprop: 'url',
        iiurlwidth: options && options[:iiurlwidth] ? options[:iiurlwidth] : 200,
        titles: title
      }.merge( options ) )
    end

    # http://en.wikipedia.org/w/api.php?action=query&generator=random&grnnamespace=0&prop=info
    def request_random( options = {} )
      request( {
        action: 'query',
        generator: 'random',
        grnnamespace: '0',
        prop: 'info'
      }.merge( options ) )
    end

    def request( options )
      require 'open-uri'
      URI.parse( url_for( options ) ).read( 'User-Agent' => Configuration[:user_agent] )
    end

    protected

    def configuration_options
      {
        protocol: Configuration[:protocol],
        domain:   Configuration[:domain],
        path:     Configuration[:path]
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
        URI.encode( val, /#{URI::UNSAFE}|[\+&]/ )
      else
        val
      end
    end
  end
end
