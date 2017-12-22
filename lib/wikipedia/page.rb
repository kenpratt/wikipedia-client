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

    def image_thumburl
      page['imageinfo'].first['thumburl'] if page['imageinfo']
    end

    def image_descriptionurl
      page['imageinfo'].first['descriptionurl'] if page['imageinfo']
    end

    def image_urls
      image_metadata.map(&:image_url) unless image_metadata.nil?
    end

    def image_thumburls( width = nil )
      options = width.nil? ? {} : { iiurlwidth: width }
      image_metadata( options ).map(&:image_thumburl) unless image_metadata( options ).nil?
    end

    def image_descriptionurls
      image_metadata.map(&:image_descriptionurl) unless image_metadata.nil?
    end

    def main_image_url
      page['thumbnail']['source'].sub(/\/thumb/, '').sub(/\/[^\/]*$/, '') if page['thumbnail']
    end

    def main_image_thumburl
      page['thumbnail']['source'] if page['thumbnail']
    end

    def coordinates
      page['coordinates'].first.values if page['coordinates']
    end

    def raw_data
      @data
    end

    def image_metadata( options = {} )
      unless @cached_image_metadata
        return if images.nil?
        filtered = images.select { |i| i =~ /:.+\.(jpg|jpeg|png|gif|svg)$/i && !i.include?('LinkFA-star') }
        @cached_image_metadata = filtered.map { |title| Wikipedia.find_image(title, options) }
      end
      @cached_image_metadata || []
    end

    def templates
      page['templates'].map { |c| c['title'] } if page['templates']
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.sanitize(s)
      return unless s

      # Transform punctuation templates
      # Em dash (https://en.wikipedia.org/wiki/Template:Em_dash)
      s.gsub!(/\{\{(em dash|emdash)\}\}/i, '&mdash;')
      # En dash (https://en.wikipedia.org/wiki/Template:En_dash)
      s.gsub!(/\{\{(en dash|ndash|nsndns)\}\}/i, '&ndash;')
      # Spaced en dashes (https://en.wikipedia.org/wiki/Template:Spaced_en_dash_space)
      s.gsub!(/\{\{(spaced e?n\s?dash( space)?|snds?|spndsp|sndashs|spndashsp)\}\}/i, '&nbsp;&ndash;&nbsp;')
      # Bold middot
      s.gsub!(/\{\{(·|dot|middot|\,)\}\}/i, '&nbsp;<b>&middot;</b>')
      # Bullets
      s.gsub!(/\{\{(•|bull(et)?)\}\}/i, '&nbsp;&bull;')
      # Forward Slashes (https://en.wikipedia.org/wiki/Template:%5C)
      s.gsub!(/\{\{\\\}\}/i, '&nbsp;/')

      # Transform language specific blocks
      s.gsub!(/\{\{lang[\-\|]([a-z]+)\|([^\|\{\}]+)(\|[^\{\}]+)?\}\}/i, '<span lang="\1">\2</span>')

      # Parse Old Style Date template blocks
      # Old Style Dates (https://en.wikipedia.org/wiki/Template:OldStyleDate)
      s.gsub!(/\{\{OldStyleDate\|([^\|]*)\|([^\|]*)\|([^\|]*)\}\}/i, '\1 [<abbr title="Old Style">O.S.</abbr> \3] \2')
      # Old Style Dates with different years (https://en.wikipedia.org/wiki/Template:OldStyleDateDY)
      s.gsub!(/\{\{OldStyleDateDY\|([^\|]*)\|([^\|]*)\|([^\|]*)\}\}/i, '\1 \2 [<abbr title="Old Style">O.S.</abbr> \3]')
      # Old Style Dates with no year (https://en.wikipedia.org/wiki/Template:OldStyleDateNY)
      s.gsub!(/\{\{OldStyleDateNY\|([^\|]*)\|([^\|]*)\}\}/i, '\1 [<abbr title="Old Style">O.S.</abbr> \2]')

      # strip anything else inside curly braces!
      s.gsub!(/\{\{[^\{\}]+?\}\}[\;\,]?/, '') while s =~ /\{\{[^\{\}]+?\}\}[\;\,]?/

      # strip info box
      s.sub!(/^\{\|[^\{\}]+?\n\|\}\n/, '')

      # strip internal links
      s.gsub!(/\[\[([^\]\|]+?)\|([^\]\|]+?)\]\]/, '\2')
      s.gsub!(/\[\[([^\]\|]+?)\]\]/, '\1')

      # strip images and file links
      s.gsub!(/\[\[Image:(.*?(?=\]\]))??\]\]/, '')
      s.gsub!(/\[\[File:(.*?(?=\]\]))??\]\]/, '')

      # convert bold/italic to html
      s.gsub!(/'''''(.+?)'''''/, '<b><i>\1</i></b>')
      s.gsub!(/'''(.+?)'''/, '<b>\1</b>')
      s.gsub!(/''(.+?)''/, '<i>\1</i>')

      # misc
      s.gsub!(/(\d)<ref[^<>]*>[\s\S]*?<\/ref>(\d)/, '\1&nbsp;&ndash;&nbsp;\2')
      s.gsub!(/<ref[^<>]*>[\s\S]*?<\/ref>/, '')
      s.gsub!(/<ref(.*?(?=\/>))??\/>/, '')
      s.gsub!(/<!--[^>]+?-->/, '')
      s.gsub!(/\(\s+/, '(')
      s.gsub!('  ', ' ')
      s.strip!

      # create paragraphs
      sections = s.split("\n\n")
      s =
        if sections.size > 1
          sections.map { |paragraph| "<p>#{paragraph.strip}</p>" }.join("\n")
        else
          "<p>#{s}</p>"
        end

      s
    end
  end
end
