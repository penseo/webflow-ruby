require 'test_helper'

class WebflowConfigTest < Minitest::Test
  def test_it_saves_api_token
    config.api_token = 'api_token'

    assert_equal('api_token', config.api_token)

    config.api_token = nil
  end

  def config
    @config ||= Webflow::Config.new
  end
end
