#!/usr/bin/env ruby

require 'json'
require 'open-uri'

def get_threads
  JSON.parse(open('https://www.reddit.com/r/EarthPorn/hot.json').read)
rescue OpenURI::HTTPError => error
  raise error unless error.io.status.first == '429'
  puts 'Got a 429, guess Reddit is busy right now. I\'ll try again in a bit <3'
  sleep 60
  get_threads
end

def get_random_thread
  get_threads['data']['children'].map { |thread|
    thread['data'] if thread['data']['domain'] == 'i.redd.it'
  }.compact.sample
end

def download(thread)
  url = thread['url']
  puts "Downloading #{url}"
  open(url) do |stream|
    open(File.expand_path('~/background.jpg'), "w") do |fout|
      while (buffer = stream.read(8192))
        fout.write buffer
      end
    end
  end
end

download(get_random_thread)
