require 'nest_thermostat'

nest_user = ENV['NEST_USER']
nest_password = ENV['NEST_PASSWORD']

SCHEDULER.every '1m', :first_in => 0 do |job|
	nest = NestThermostat::Nest.new({email: nest_user,password: nest_password})
	first_nest = nest.status["shared"][nest.device_id]
	temp = nest.temperature; 
	away = nest.away
	state = "off"	
	leaf_src = ""

	if(first_nest['hvac_ac_state'])
		state = "cooling"
	elsif (first_nest['hvac_heater_state'])
		state = "heating"
	end
	
	if(nest.leaf)
		leaf_src = "assets/nest_leaf.png"
	end

	send_event('nest', { temp: temp.to_i , state: state, away: away, leaf: leaf_src })
end
