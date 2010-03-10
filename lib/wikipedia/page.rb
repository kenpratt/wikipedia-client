module Wikipedia
  class Page
    def initialize(json)
      require 'json'
      @data = JSON::load(json)
    end

    def content
      @data['query']['pages'].values.first['revisions'].first.values.first
    end

    def redirect?
      content.match(/\#REDIRECT\s+\[\[(.*?)\]\]/)
    end

    def redirect_title
      if matches = redirect?
        matches[1]
      end
    end

    def title
      @data['query']['pages'].values.first['title']
    end

    def categories
      @data['query']['pages'].values.first['categories'].map {|c| c['title'] }
    end

    def links
      @data['query']['pages'].values.first['links'].map {|c| c['title'] }
    end

    def images
      @data['query']['pages'].values.first['images'].map {|c| c['title'] }
    end

    def image_url
      @data['query']['pages'].values.first['imageinfo'].first['url']
    end

    def image_urls
      images.map do |title|
        Wikipedia.find_image( title ).image_url
      end
    end

    def raw_data
      @data
    end
  end
end
