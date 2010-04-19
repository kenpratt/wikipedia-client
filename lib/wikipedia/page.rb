module Wikipedia
  class Page
    def initialize(json)
      require 'json'
      @json = json
      @data = JSON::load(json)
    end

    def page
      @data['query']['pages'].values.first
    end

    def content
      page['revisions'].first.values.first if page['revisions']
    end

    def sanitized_content
      self.class.sanitize(content)
    end

    def redirect?
      content && content.match(/\#REDIRECT\s+\[\[(.*?)\]\]/i)
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
      if list = images
        filtered = list.select {|i| i =~ /^file:.+\.(jpg|jpeg|png|gif)$/i && !i.include?("LinkFA-star") }
        filtered.map do |title|
          Wikipedia.find_image( title ).image_url
        end
      end
    end

    def raw_data
      @data
    end

    def json
      @json
    end

    def self.sanitize( s )
      if s
        s = s.dup

        # strip anything inside curly braces!
        while s =~ /\{\{[^\{\}]+?\}\}/
          s.gsub!(/\{\{[^\{\}]+?\}\}/, '')
        end

        # strip info box
        s.sub!(/^\{\|[^\{\}]+?\n\|\}\n/, '')

        # strip internal links
        s.gsub!(/\[\[([^\]\|]+?)\|([^\]\|]+?)\]\]/, '\2')
        s.gsub!(/\[\[([^\]\|]+?)\]\]/, '\1')

        # strip images and file links
        s.gsub!(/\[\[Image:[^\[\]]+?\]\]/, '')
        s.gsub!(/\[\[File:[^\[\]]+?\]\]/, '')

        # convert bold/italic to html
        s.gsub!(/'''''(.+?)'''''/, '<b><i>\1</i></b>')
        s.gsub!(/'''(.+?)'''/, '<b>\1</b>')
        s.gsub!(/''(.+?)''/, '<i>\1</i>')

        # misc
        s.gsub!(/<ref[^<>]*>[\s\S]*?<\/ref>/, '')
        s.gsub!(/<!--[^>]+?-->/, '')
        s.gsub!('  ', ' ')
        s.strip!

        # create paragraphs
        sections = s.split("\n\n")
        if sections.size > 1
          s = sections.map {|s| "<p>#{s.strip}</p>" }.join("\n")
        end

        s
      end
    end
  end
end
