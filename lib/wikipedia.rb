Dir[File.dirname(__FILE__) + '/wikipedia/**/*.rb'].each { |f| require f }

require 'uri'

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
  def self.find( page, options = {} )
    client.find( page, options )
  end

  def self.find_image( title, options = {} )
    client.find_image( title, options )
  end

  def self.find_random( options = {} )
    client.find_random( options )
  end

  def self.configure(&block)
    Configuration.instance.instance_eval(&block)
  end

  # rubocop:disable Style/MethodName
  def self.Configure(&block)
    configure(&block)
  end

  configure do
    protocol  'https'
    domain    'en.wikipedia.org'
    path      'w/api.php'
    user_agent(
      'wikipedia-client/1.7 (https://github.com/kenpratt/wikipedia-client)'
    )
  end

  class << self
    private

    def client
      @client ||= Wikipedia::Client.new
    end
  end
end
