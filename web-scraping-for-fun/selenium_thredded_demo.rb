#!/usr/bin/env ruby

require "selenium-webdriver"

driver = Selenium::WebDriver.for :chrome
driver.manage.window.resize_to(1024, 768)
sleep 5

# Log in as a user
driver.navigate.to 'https://thredded.org/user_sessions/new'
element = driver.find_element(name: 'name')
# Send backspace three times to clear the form
3.times { element.send_keys :backspace }
element.send_keys 'Selenium'
element.submit

# Go into the off-topic area
driver.find_element(partial_link_text: 'Off-Topic').click

# Wait for turbolinks to finish loading the next page
# (My internet obviously sucks)
sleep 5

# Create a new thread
element = driver.find_element(id: 'topic_title')
element.send_keys 'Web Scraping with Selenium'
# Wait for CSS animations to finish
sleep 1
element = driver.find_element(id: 'topic_content')
element.send_keys "It's _super_ cool, you should check out the [GitHub](https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings)!"
element.submit

# Close the browser
driver.quit
