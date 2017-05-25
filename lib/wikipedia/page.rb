module Wikipedia
  class Page
    attr_reader :json

    def initialize(json)
      require 'json'
      @json = json
      @data = JSON.parse(json)
    end

    def page
      @data['query']['pages'].values.first if @data['query']['pages']
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
      redirect?[1] rescue nil
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

    def text
      page['extract']
    end

    def summary
      page['extract'].split('==')[0].strip if page['extract'] && page['extract'] != ''
    end

    def categories
      page['categories'].map { |c| c['title'] } if page['categories']
    end

    def links
      page['links'].map { |c| c['title'] } if page['links']
    end

    def extlinks
      page['extlinks'].map { |c| c['*'] } if page['extlinks']
    end

    def images
      page['images'].map { |c| c['title'] } if page['images']
    end

    def image_url
      page['imageinfo'].first['url'] if page['imageinfo']
    end

    def image_descriptionurl
      page['imageinfo'].first['descriptionurl'] if page['imageinfo']
    end

    def image_urls
      image_metadata.map(&:image_url)
    end

    def image_descriptionurls
      image_metadata.map(&:image_descriptionurl)
    end

    def coordinates
      page['coordinates'].first.values if page['coordinates']
    end

    def raw_data
      @data
    end

    def image_metadata
      unless @cached_image_metadata
        return if images.nil?
        filtered = images.select { |i| i =~ /:.+\.(jpg|jpeg|png|gif|svg)$/i && !i.include?('LinkFA-star') }
        @cached_image_metadata = filtered.map { |title| Wikipedia.find_image(title) }
      end
      @cached_image_metadata || []
    end

    def templates
      page['templates'].map { |c| c['title'] } if page['templates']
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.sanitize( s )
      return unless s

      # strip anything inside curly braces!
      s.gsub!(/\{\{[^\{\}]+?\}\}/, '') while s =~ /\{\{[^\{\}]+?\}\}/

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
        s = sections.map { |paragraph| "<p>#{paragraph.strip}</p>" }.join("\n")
      end

      s
    end
  end
end
