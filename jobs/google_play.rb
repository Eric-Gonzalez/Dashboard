#!/usr/bin/env ruby
require 'market_bot'
 
appIds = 'com.ericrgon.postmark','com.forty_eightdp.kana','com.bypasslane.bypasslane','com.bypasslane.access','com.bypasslane.bypasslane.mot'
apps = Array.new
appIds.each do |app|
	apps.push(MarketBot::Android::App.new(app))
end
 
SCHEDULER.every '30m', :first_in => 0 do |job|
	stats = Array.new
	# prepare request  
	apps.each do |app|
		app.update
		stats.push({ label: app.title[0..15], value: app.rating, count: app.votes})
	end
	stats.sort! { |a,b| b[:value] <=> a[:value] }
	send_event('google_play_stats', { items: stats })
end