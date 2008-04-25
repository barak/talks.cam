#!/usr/bin/env ruby

# This is an example of a script that uploads talks to talk.cam
# The example is written in Ruby (www.ruby-lang.org) and only uses its standard libraries
# It should be easy to translate into other languages.

# First of all we need a destination
# talks_url = "0.0.0.0"
# talks_port = 3000
 talks_url = "talks.cam.ac.uk"
 talks_port = 80

# Then we need user details (this person must have been registered on talks.cam)
email = "tamc2@cam.ac.uk"
password = 'not a real password'

# Here are some example details about the talk
series_name = "A very interesting seminar series" # Note, if series doesn't exist it will be created.
organiser_email = "organiser-of-interesting-seminars@talks.cam.ac.uk"

title = "A new talk title"
abstract = "This is an interesting talk"

date = "2007/05/15" # Note format yyyy/mm/dd
start_time = "15:00" # Note 24hr clock
end_time = "17:00"

speaker_email = "a.speaker@talks.cam.ac.uk"
name_of_speaker = "William E. B. Master, University of Cambridge"

special_message = "Note unusual venue"
venue_name = "A venue that has never been seen before"

# Which we now rearrange into some XML
# In ruby, #{something} in a string inserts the content of that variable
xml = <<ENDOFXML
<?xml version="1.0" encoding="UTF-8"?>
<talk>
  <series_name>#{series_name}</series_name>
  <organiser_email>#{organiser_email}</organiser_email>
  <title>#{title}</title>
  <abstract>#{abstract}</abstract>
  <date-string>#{date}</date-string>
  <start-time-string>#{start_time}</start-time-string>
  <end-time-string>#{end_time}</end-time-string>
  <speaker-email>#{speaker_email}</speaker-email>
  <name-of-speaker>#{name_of_speaker}</name-of-speaker>
  <special-message>#{special_message}</special-message>
  <venue-name>#{venue_name}</venue-name>
</talk>
ENDOFXML

# Then we need to post the xml to the talks.cam service

# This uses a built in ruby library for doing http requests
require 'net/http'
connection = Net::HTTP.new( talks_url, talks_port )
headers = {}

# We are sending, and where possible hoping for, xml
headers['Content-Type'] = 'application/xml'
headers['Accept'] = 'application/xml'

# We are using the basic http authentication scheme http://en.wikipedia.org/wiki/Basic_authentication_scheme
headers['Authorization'] = 'Basic ' + ["#{email}:#{password}"].pack('m').delete("\r\n")

response = connection.send(:post, '/talk/update', xml, headers )
puts case response.code.to_i
when 200; "Ok., Saved at #{response['Location']}"
when 302; "Password or username incorrect"
else       "#{response.code}: #{response.body}"
end

# Alternatively could use the curl command
# command = 
# "curl " + # http://curl.haxx.se
# "-H 'Accept: application/xml' " + # We only want xml in reply
# "-H 'Content-Type: application/xml' " + # We are sending xml
# "-X POST " + # We are posting the data
# "-u #{email}:#{password} " + # We are using the basic http authentication scheme http://en.wikipedia.org/wiki/Basic_authentication_scheme
# "-d '#{xml}' " + # We are sending the data
# "-w 'HTTP STATUS: %{http_code} TIME: %{time_total}' " + # We want to hear what happened
# "#{talks_url}/talk/update " # This is where we want it to go
# puts command
# puts `#{command}`
