#!/usr/bin/env ruby

require 'mechanize'

session = Mechanize.new
# Log in as a user
session.get('https://thredded.org/user_sessions/new')
form = session.page.forms.last
form['name'] = 'Jane'
form.submit

# Confirm we are logged in
session.page.parser.css('.thredded--flash-message').map(&:text).map(&:strip)
#=> ["Signed in as Jane, an admin."]

# Go into the off-topic area
session.page.links[8].click

# Create a new thread
form = session.page.forms.last
form['topic[title]'] = 'Web Scraping with Mechanize'
form['topic[content]'] =
  "It's _super_ cool, you should check out the [GitHub](https://github.com/sparklemotion/mechanize)!"
form.submit
