$:.unshift File.expand_path('lib')

require 'webflow'

TEST_API_TOKEN = '1f0da5c9368af9cb2dcd65d22a6600a8ffa069f70729e129a09787203bc2c2be'
@client = Webflow::Client.new(TEST_API_TOKEN)
