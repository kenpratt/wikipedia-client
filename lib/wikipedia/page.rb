module Wikipedia
  class Page
    def initialize(json)
      require 'json'
      @data = JSON::load(json)
    end

    def page
      @data['query']['pages'].values.first
    end

    def content
      page['revisions'].first.values.first if page['revisions']
    end

    def redirect?
      content && content.match(/\#REDIRECT\s+\[\[(.*?)\]\]/)
    end

    def redirect_title
      if matches = redirect?
        matches[1]
      end
    end

    def title
      page['title']
    end

    def categories
      page['categories'].map {|c| c['title'] } if page['categories']
    end

    def links
      page['links'].map {|c| c['title'] } if page['links']
    end

    def images
      page['images'].map {|c| c['title'] } if page['images']
    end

    def image_url
      page['imageinfo'].first['url'] if page['imageinfo']
    end

    def image_urls
      images.map do |title|
        Wikipedia.find_image( title ).image_url
      end if images
    end

    def raw_data
      @data
    end
  end
end
