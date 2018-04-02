#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

def hackernews_front_page
  document = Nokogiri::HTML(open('https://news.ycombinator.com/').read)
  # Each hackernews item is actually contained in 3 tr elements without nice
  # classes on them. And there are two lines at the end we don't care about,
  # hence the check for how many elements we have.
  results = []
  document.css('.itemlist tr').each_slice(3) { |element|
    next unless element.size == 3
    user_element = element[1].at_css('.hnuser')

    results << {
      rank: element[0].at_css('.rank').text.gsub('.', '').to_i,
      story: {
        title: element[0].at_css('.title a').text,
        link: element[0].at_css('.title a')[:href]
      },
      user: {
        name: user_element ? user_element.text : nil,
        link: user_element ? user_element[:href] : nil
      },
      comments: {
        count: element[1].css('.subtext a').last.text.to_i,
        link: element[1].css('.subtext a').last[:href]
      }
    }
  }

  results
end

p hackernews_front_page[0]
#=> {
#     :rank=>1,
#     :story=>{
#       :title=>"How Cambridge Analytica’s Facebook targeting model really worked",
#       :link=>"http://www.niemanlab.org/2018/03/this-is-how-cambridge-analyti..."
#     },
#     :user=>{
#       :name=>"Dowwie",
#       :link=>"user?id=Dowwie"
#     },
#     :comments=>{
#       :count=>128,
#       :link=>"item?id=16719403"
#     }
#   }
