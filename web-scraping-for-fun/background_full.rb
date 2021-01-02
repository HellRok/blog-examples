#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'rbconfig'

WALLPAPER_PATH = File.expand_path(
  ENV['WALLPAPER_PATH'] || '~/background.jpg'
)
ARCHIVE_PATH = File.expand_path(
  ENV['ARCHIVE_PATH'] || '~/Pictures/EarthPorn'
)

# Source: https://stackoverflow.com/a/1939351
def sanitize_filename(filename)
  filename = filename.strip
  # NOTE: File.basename doesn't work right with Windows paths on Unix
  # get only the filename, not the whole path
  filename.gsub!(/^.*(\\|\/)/, '')

  # Strip out the non-ascii character
  filename.gsub!(/[^0-9A-Za-z.\- \[\]]/, '')

  filename
end

def get_threads
  JSON.parse(URI.open('https://www.reddit.com/r/EarthPorn/hot.json').read)
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

def download_and_link(thread)
  url = thread['url']
  filename = sanitize_filename([
    "[#{thread['author']}]",
    "[#{thread['subreddit']}]",
    "[#{thread['id']}]",
    "#{thread['title']}",
  ].join(' '))
  filename << ".#{url.split('.').last.split('?').first}"

  puts "Downloading #{filename}"

  URI.open(url) do |stream|
    open(File.join(ARCHIVE_PATH, filename), "w") do |fout|
      while (buffer = stream.read(8192))
        fout.write buffer
      end
    end
  end
  File.delete(WALLPAPER_PATH) if File.symlink?(WALLPAPER_PATH) || File.exists?(WALLPAPER_PATH)
  File.symlink(
    File.join(ARCHIVE_PATH, filename),
    WALLPAPER_PATH
  )
end

def set_wallpaper
  case RbConfig::CONFIG['host_os']
    when /darwin|mac os/
      `defaults write com.apple.desktop Background '{default = {ImageFilePath = "~/background.jpg"; };}'`
      `killall Dock`
    when /linux/
      # Nothing to do
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      # TODO
  end
end

download_and_link(get_random_thread)
set_wallpaper
