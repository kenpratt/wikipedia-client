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
      page['revisions'].first['*'] if page['revisions']
    end

    def sanitized_content
      self.class.sanitize(content)
    end

    def redirect?
      content && content.match(/\#REDIRECT\s*\[\[(.*?)\]\]/i)
    end

    def redirect_title
      if matches = redirect?
        matches[1]
      end
    end

    def title
      page['title']
    end

    def fullurl
      page['fullurl']
    end

    def editurl
      page['editurl']
    end

    def categories
      page['categories'].map {|c| c['title'] } if page['categories']
    end

    def links
      page['links'].map {|c| c['title'] } if page['links']
    end

    def extlinks
      page['extlinks'].map {|c| c['*'] } if page['extlinks']
    end

    def images
      page['images'].map {|c| c['title'] } if page['images']
    end

    def image_url
      page['imageinfo'].first['url'] if page['imageinfo']
    end

    def image_descriptionurl
      page['imageinfo'].first['descriptionurl'] if page['imageinfo']
    end

    def image_urls
      image_metadata.map {|img| img.image_url }
    end

    def image_descriptionurls
      image_metadata.map {|img| img.image_descriptionurl }
    end

    def coordinates
      page['coordinates'].first.values if page['coordinates']
    end

    def raw_data
      @data
    end

    def image_metadata
      unless @cached_image_metadata
        if list = images
          filtered = list.select {|i| i =~ /:.+\.(jpg|jpeg|png|gif)$/i && !i.include?("LinkFA-star") }
          @cached_image_metadata = filtered.map {|title| Wikipedia.find_image(title) }
        end
      end
      @cached_image_metadata || []
    end

    def templates
      page['templates'].map {|c| c['title'] } if page['templates']
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
