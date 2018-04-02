#!/usr/bin/env ruby

require 'net/https'

def should_i_fetch?(path)
  uri = URI(path)

  # We only handle HTTP and HTTPS
  return false unless ['http', 'https'].include?(uri.scheme)

  connection = Net::HTTP.new(uri.host, uri.port)
  connection.use_ssl = (uri.scheme == 'https')
  head = connection.request_head(uri.path)
  return false unless head.content_type == 'text/html'
  return false unless (head.content_length || 0) <= 1024 * 1024 * 5 # 5 Megabytes
  true
end

ftp_site = 'ftp://speedtest.tele2.net/'
big_file = 'http://mirror.filearena.net/pub/speed/SpeedTest_2048MB.dat'
regular_site = 'https://www.adam.com.au/support/blank-test-files'
json_api = 'https://www.reddit.com/r/EarthPorn/hot.json'

puts should_i_fetch? ftp_site
#=> false
puts should_i_fetch? json_api
#=> false
puts should_i_fetch? big_file
#=> false
puts should_i_fetch? regular_site
#=> true

