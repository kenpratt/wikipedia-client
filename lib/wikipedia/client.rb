module Wikipedia
  class Client
    @@url = "http://:domain/:path?action=:action&prop=revisions&titles=:page&rvprop=:properties&format=json"
    
    attr_accessor :follow_redirects
    
    def initialize
      self.follow_redirects = true
    end
    
    def find( title )
      title = Url.new(title).title rescue title
      page = Page.new( request( title ) )
      while follow_redirects and page.redirect?
        page = Page.new( request( page.redirect_title ))
      end
      page
    end
    
    def request( page )
      require 'open-uri'
      URI.parse( url_for(page) ).read
    end
    
    protected 
      def url_keys_for( page )
        {
          :domain => Configuration[:domain],
          :path   => Configuration[:path],
          :action => Configuration[:action],
          :page   => URI.encode(page),
          :properties => [Configuration[:properties]].flatten.join('|')
        }
      end
      
      def url_for( page )
        ret = @@url.dup
        url_keys_for( page ).each do |key, value|
          ret.sub! ":#{key}", value
        end
        ret
      end
  end
end