require 'simple-rss'
require 'open-uri'

url     = 'http://feeds.feedburner.com/StartupQuote?format=xml'
feed    = SimpleRSS.parse open(url)
entries = feed.entries

SCHEDULER.every '1m', :first_in => 0 do
  random_quote = entries.sample
  if (src = random_quote.description.match(/img.*?src="(.*?)"/i)[1] rescue false)
    send_event('startup_quote', {image: src})
  end
end