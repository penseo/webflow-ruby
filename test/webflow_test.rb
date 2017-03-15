require 'test_helper'

TEST_API_TOKEN = 'c39d97f0ff14af5824b85c660e9cb86e59a6156c3209a491ace867477e9252e6'

class WebflowTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Webflow::VERSION
  end

  def test_it_fetches_sites
    webflow = Webflow::Client.new(TEST_API_TOKEN)

    assert_equal '58c996aa4e6fd9182228b630', webflow.sites.first['_id']
  end
end
