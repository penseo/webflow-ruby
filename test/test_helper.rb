$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'webflow'
require 'byebug'
require 'vcr'

VCR.configure do |config|
  config.default_cassette_options = { record: :new_episodes }
  config.cassette_library_dir = 'test/fixtures/cassettes'
  config.hook_into :webmock # or :fakeweb
end

require 'minitest/autorun'
