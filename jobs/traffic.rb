require 'net/http'
require 'net/https'
require 'uri'
require 'json'
 
office_location = URI::encode(ENV['HOME_GEO_CODE'])
key			    = URI::encode(ENV['TOMTOM_API_KEY'])
locations 	 = []
locations << { name: "Violet Crown", location: URI::encode('30.2654559,-97.74821459999998')}
locations << { name: "Thunderbird", location: URI::encode('30.330823,-97.73192999999998')}
locations << { name: "IBM", location: URI::encode('30.4005547,-97.71570150000002') }
 
SCHEDULER.every '10m', :first_in => '15s' do |job|
	routes = []
 
	# pull data
	locations.each do |location|
		uri = URI.parse("https://api.tomtom.com/lbs/services/route/3/#{office_location}:#{location[:location]}/Quickest/json?avoidTraffic=true&includeTraffic=true&language=en&day=today&time=now&iqRoutes=2&avoidTolls=false&includeInstructions=true&projection=EPSG4326&key=#{key}")
		print uri
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		print response.to_s

		routes << { name: location[:name], location: location[:location], route: JSON.parse(response.body)["route"] }
	end
 
	# find winner
	if routes
		routes.sort! { |route1, route2| route2[:route]["summary"]["totalTimeSeconds"] <=> route1[:route]["summary"]["totalTimeSeconds"] }
		routes.map! do |r|
			{ name: r[:name],
				time: seconds_in_words(r[:route]["summary"]["totalTimeSeconds"]),
				road: delay(r[:route]["summary"]["totalDelaySeconds"]) + longest_leg(r[:route]["instructions"]["instruction"]) }
		end
	end
 
	# send event
  send_event('tomtom', { results: routes } )
end
 
def seconds_in_words(secs)
	m, s = secs.divmod(60)
	h, m = m.divmod(60)
 
	plural_hours = if h > 1 then "s" else "" end
	plural_minutes = if m > 1 then "s" else "" end
 
	if secs >= 3600
		"#{h} hour#{plural_hours}, #{m} min#{plural_minutes}"
	else
		"#{m} min#{plural_minutes}"
	end
end
 
def longest_leg(instructions)
	instructions.sort! { |leg1, leg2| leg2["travelTimeSeconds"] <=> leg1["travelTimeSeconds"] }
	if instructions[0]["roadNumber"].empty?
		instructions[0]["roadName"]
	elsif instructions[0]["roadName"].empty?
		instructions[0]["roadNumber"]
	else
		"#{instructions[0]["roadName"]}, #{instructions[0]["roadNumber"]}"
	end
end
 
def delay(delay_seconds)
	m, s = delay_seconds.divmod(60)
	h, m = m.divmod(60)
 
	if delay_seconds >= 60
		"#{m} min delay on "
	elsif delay_seconds == 0
		""
	else
		"#{s} sec delay on "
	end
end
