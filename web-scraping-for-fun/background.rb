#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'rbconfig'

def sanitize_filename(filename)
  filename = filename.strip
  # NOTE: File.basename doesn't work right with Windows paths on Unix
  # get only the filename, not the whole path
  filename.gsub!(/^.*(\\|\/)/, '')

  # Strip out the non-ascii character
  filename.gsub!(/[^0-9A-Za-z.\- \[\]]/, '')

  filename
end

def try_really_hard_to_get_threads
  return JSON.parse(open('https://www.reddit.com/r/EarthPorn/hot.json').read)
rescue OpenURI::HTTPError => e
  puts 'GOT A 429 (PROBABLY), SLEEPING A BIT UNTIL TRYING AGAIN'
  sleep 60
  return try_really_hard_to_get_threads
end

threads = try_really_hard_to_get_threads

images = []

threads['data']['children'].each do |thread|
  if thread['data']['domain'] == 'i.redd.it'
    images << thread['data']
  end
end

image = images.sample(1).first
url = image['url']
filename = sanitize_filename([
  "[#{image['author']}]",
  "[#{image['subreddit']}]",
  "[#{image['id']}]",
  "#{image['title']}",
].join(' '))
filename << ".#{url.split('.').last.split('?').first}"

case RbConfig::CONFIG['host_os']
  when /darwin|mac os/
    `cd ~/Pictures/EarthPorn && wget "#{url}" -O "#{filename}"`
    `cp "#{ENV['HOME']}/Pictures/EarthPorn/#{filename}" ~/background.jpg`
    `defaults write com.apple.desktop Background '{default = {ImageFilePath = "~/background.jpg"; };}'`
    `killall Dock`
  when /linux/
    `cd ~/Pictures && wget "#{url}" -O "#{filename}"`
    `cp "#{ENV['HOME']}/Pictures/#{filename}" ~/background.jpg`
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    # TODO
end
