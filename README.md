# Wikipedia API CLient

[![Gem Version](https://badge.fury.io/rb/wikipedia-client.svg)](https://badge.fury.io/rb/wikipedia-client)
[![Build Status](https://github.com/kenpratt/wikipedia-client/workflows/Test/badge.svg)](https://github.com/kenpratt/wikipedia-client/actions?query=workflow%3ATest)


Allows you to get wikipedia content through their API. This uses the
alpha API, not the deprecated query.php API type.

Wikipedia API reference: <http://en.wikipedia.org/w/api.php>

Adopted from: <http://code.google.com/p/wikipedia-client/>

## Installation

```
gem install wikipedia-client
```

## Usage

```ruby
require 'wikipedia'
page = Wikipedia.find( 'Getting Things Done' )
#=> #<Wikipedia:Page>

page.title
#=> 'Getting Things Done'

page.fullurl
#=> 'http://en.wikipedia.org/wiki/Getting_Things_Done'

page.text
#=> 'Getting Things Done is a time-management method...'

page.content
#=> all the wiki markup appears here...

page.summary
#=> only the wiki summary appears here...

page.categories
#=> [..., "Category:Self-help books", ...]

page.links
#=> [..., "Business", "Cult following", ...]

page.extlinks
# => [..., "http://www.example.com/", ...]

page.images
#=> ["File:Getting Things Done.jpg", ...]

page.image_urls
#=> ["http://upload.wikimedia.org/wikipedia/en/e/e1/Getting_Things_Done.jpg"]

page.image_thumburls
#=> ["https://upload.wikimedia.org/wikipedia/en/thumb/e/e1/Getting_Things_Done.jpg/200px-Getting_Things_Done.jpg"]

# or with custom width argument:
page.image_thumburls(100)
#=> ["https://upload.wikimedia.org/wikipedia/en/thumb/e/e1/Getting_Things_Done.jpg/100px-Getting_Things_Done.jpg"]

page.image_descriptionurls
#=> ["http://en.wikipedia.org/wiki/File:Getting_Things_Done.jpg"]

page.main_image_url
#=> "https://upload.wikimedia.org/wikipedia/en/e/e1/Getting_Things_Done.jpg"

page.coordinates
#=> [48.853, 2.3498, "", "earth"]

page.templates
#=> [..., "Template:About", ...]

page.langlinks
#=> {..., "de"=>"Getting Things Done", "eo"=>"Igi aferojn finitaj",  "zh"=>"尽管去做", ...}
```

## Configuration

This is by default configured like this:

```ruby
Wikipedia.configure {
  domain 'en.wikipedia.org'
  path   'w/api.php'
}
```

## Advanced

See the API spec at "http://en.wikipedia.org/w/api.php":http://en.wikipedia.org/w/api.php

If you need data that is not already present, you can override parameters.

For example, to retrieve only the page info:

```ruby
page = Wikipedia.find( 'Getting Things Done', :prop => "info" )

page.title
#=> "Getting Things Done"

page.raw_data
#=> {"query"=>{"pages"=>{"959928"=>{"pageid"=>959928, "ns"=>0,
"title"=>"Getting Things Done", "touched"=>"2010-03-10T00:04:09Z",
"lastrevid"=>348481810, "counter"=>0, "length"=>7891}}}}
```

## Contributing

### Getting the code, and running the tests

```
git clone git@github.com:kenpratt/wikipedia-client.git
cd wikipedia-client
bundle install
bundle exec spec
```

### Pushing a new release of the Gem

1. Edit `lib/wikipedia/version.rb`, changing `VERSION`.
2. Build the gem: `bundle exec gem build wikipedia-client.gemspec`.
3. Commit the changes: `git commit -a -m 'Version bump to 1.4.0' && git tag v1.4.0 && git push && git push --tag`
4. Publish the result to RubyGems: `bundle exec gem push wikipedia-client-1.4.0.gem`.

## Thanks!

Copyright (c) 2008 Cyril David, released under the MIT license

Adopted by Ken Pratt (ken@kenpratt.net) in 2010/03

Thanks to all the [Contributors](https://github.com/kenpratt/wikipedia-client/graphs/contributors).
