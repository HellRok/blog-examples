#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

def get_opengraph_data(uri)
  document = Nokogiri::HTML(open(uri).read)
  document.css('meta[property^="og:"]').map { |element|
    [element['property'].gsub('og:', ''), element['content']]
  }.to_h
end

p get_opengraph_data('http://www.imdb.com/title/tt0117500/')
#=> {
#     "url"=>"http://www.imdb.com/title/tt0117500/",
#     "image"=>"https://ia.media-imdb.com/images/M/MV5BZDJjOTE0N2EtMmRlZS00NzU0...",
#     "type"=>"video.movie",
#     "title"=>"The Rock (1996)",
#     "site_name"=>"IMDb",
#     "description"=>"Directed by Michael Bay.  With Sean Connery, Nicolas Cage..."
#   }
