#!/usr/bin/env ruby
require 'net/http'

athlete = ENV['STRAVA_ID']

SCHEDULER.every '10m', :first_in => 0 do |job|
  
  # prepare request  
  # http = Net::HTTP.new("www.strava.com")  

  # scrape detail page of app with appId
  # response = http.request(Net::HTTP::Get.new("/athletes/#{athlete}"))

  response = Net::HTTP.get('www.strava.com','/athletes/238937')
      
  total_distance = /<strong>([\d,.]+)<abbr class='unit' title='miles'>mi<\/abbr><\/strong>
<div class='label'>Total Distance<\/div>/.match(response)

  total_distance = total_distance[1].to_f

  send_event('strava_total_distance', current: total_distance)


  # if response.code != "200"
  #   puts "google play store website communication (status-code: #{response.code})\n#{response.body}"
  # else
  #   # capture average rating using regexp
  #   average_rating = /average-rating-value">([\d,.]+)<\/div>/.match(response.body)
  #   average_rating = average_rating[1].gsub(",", ".").to_f
  #   send_event('google_play_average_rating', current: average_rating)
  #   # print "average-rating: #{average_rating}\n"

  #   # capture
  #   voters_count = /div class="votes">([\d,.]+)<\/div>/.match(response.body)
  #   voters_count = voters_count[1].gsub('.', '').to_i
  #   send_event('google_play_voters_total', current: voters_count)
  #   # print "google_play_voters_total: #{voters_count}\n"
    
  # end
end