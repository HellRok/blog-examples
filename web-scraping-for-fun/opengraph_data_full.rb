#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

def get_opengraph_data(document)
  document.css('meta[property^="og:"]').map { |element|
    [element['property'].gsub('og:', ''), element['content']]
  }.to_h
end

def get_twitter_data(document)
  document.css('meta[property^="twitter:"]').map { |element|
    [element['property'].gsub('twitter:', ''), element['content']]
  }.to_h
end

def get_data(website)
  document = Nokogiri::HTML(open(website).read)

  {
    twitter: get_twitter_data(document),
    opengraph: get_opengraph_data(document)
  }
end

p get_data('https://www.reddit.com/r/EarthPorn/comments/875wrx/follow_the_yellow_leaf_road_oc_3000x2000_ottawa_on/')
#=> {
#     :twitter=>{
#       "site"=>"reddit",
#       "card"=>"summary",
#       "title"=>"Follow the yellow leaf road. [OC] [3000x2000] Ottawa, ON • r/EarthPorn"
#     },
#     :opengraph=>{
#       "site_name"=>"reddit",
#       "description"=>"409 points and 5 comments so far on reddit",
#       "title"=>"Follow the yellow leaf road. [OC] [3000x2000] Ottawa, ON • r/EarthPorn",
#       "image"=>"https://i.redditmedia.com/0vZXHTnEKWFmcp8CRztEA92aBl5Af_A9maMHivBTkRk.jpg...",
#       "ttl"=>"600",
#       "image:width"=>"320"
#     }
#   }

p get_data('http://www.imdb.com/title/tt0117500/')
#=> {
#     :twitter=>{},
#     :opengraph=>{
#       "url"=>"http://www.imdb.com/title/tt0117500/",
#       "image"=>"https://ia.media-imdb.com/images/M/MV5BZDJjOTE0N2EtMmRlZS00NzU0LWE0ZWQtM2...",
#       "type"=>"video.movie",
#       "title"=>"The Rock (1996)",
#       "site_name"=>"IMDb",
#       "description"=>"Directed by Michael Bay.  With Sean Connery, Nicolas Cage, Ed Harri..."
#     }
#   }
