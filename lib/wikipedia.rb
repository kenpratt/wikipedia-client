Dir[File.dirname(__FILE__) + '/wikipedia/**/*.rb'].each { |f| require f }

module Wikipedia
  # Examples : 
  # page = Wikipedia.find('Rails') 
  # => #<Wikipedia:0x123102>
  # page.content
  # => wiki content appears here
  
  # basically just a wrapper for doing 
  # client = Wikipedia::Client.new
  # client.find('Rails')
  #
  def self.find( page )
    @client ||= Wikipedia::Client.new
    @client.find( page )
  end
  
  def self.Configure(&block)
    Configuration.instance.instance_eval(&block)
  end
  
  Configure {
    domain 'en.wikipedia.org'
    path   'w/api.php'
    action 'query'
    properties 'content'
  }
end