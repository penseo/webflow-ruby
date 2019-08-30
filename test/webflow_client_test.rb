require 'test_helper'

class WebflowClientTest < Minitest::Test
  def test_it_uses_configured_api_token_when_it_exists
    Webflow.config.api_token = 'api_token'

    client = Webflow::Client.new('given_token')

    assert_equal('api_token', client.instance_variable_get('@token'))
  end

  def test_it_uses_given_api_token_when_configured_token_does_not_exist
    Webflow.config.api_token = nil

    client = Webflow::Client.new('given_token')

    assert_equal('given_token', client.instance_variable_get('@token'))
  end
end
