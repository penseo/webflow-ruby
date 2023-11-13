$LOAD_PATH.unshift File.expand_path('lib')

require 'webflow'

@client = Webflow::Client.new(ENV.fetch('TEST_API_TOKEN'))
