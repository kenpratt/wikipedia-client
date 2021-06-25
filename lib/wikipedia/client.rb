require 'addressable'
require 'cgi'
require 'open-uri'
require 'set'

module Wikipedia
  class Client
    # see http://en.wikipedia.org/w/api.php
    BASE_URL_TEMPLATE = '%{protocol}://%{domain}/%{path}?action=%{action}&format=json'.freeze
    BASE_URL_OPTIONS = Set.new([:protocol, :domain, :path, :action])

    attr_accessor :follow_redirects

    def initialize(configuration = Wikipedia::Configuration.new)
      @configuration = configuration
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
        prop: %w[info revisions links extlinks images categories coordinates templates extracts pageimages langlinks],
        rvprop: 'content',
        inprop: 'url',
        pithumbsize: 200,
        explaintext: '',
        lllimit: 500,
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
      URI.parse( url_for( options ) ).read( 'User-Agent' => @configuration[:user_agent] )
    end

    protected

    def configuration_options
      {
        protocol: @configuration[:protocol],
        domain:   @configuration[:domain],
        path:     @configuration[:path]
      }
    end

    def url_for(options)
      options = configuration_options.merge( options )

      url_options, query_options = split_hash(options, BASE_URL_OPTIONS)
      normalized_query_options = query_options.map { |k, v| [k, normalize_value(v)] }

      base_url = BASE_URL_TEMPLATE % url_options
      query_string = Addressable::URI.form_encode(normalized_query_options)
      base_url + '&' + query_string
    end

    def normalize_value( val )
      case val
      when Array
        val.flatten.join( '|' )
      else
        val
      end
    end

    def split_hash(hash, keys)
      h1 = {}
      h2 = {}
      hash.each do |k, v|
        (keys.include?(k) ? h1 : h2).store(k, v)
      end
      [h1, h2]
    end
  end
end
