require 'test_helper'

TEST_API_TOKEN = '1f0da5c9368af9cb2dcd65d22a6600a8ffa069f70729e129a09787203bc2c2be'
SITE_ID = '58c9a534b6b690592691fe96'
COLLECTION_ID = '58c9a554a118f71a388bcc89'
DOMAIN = 'webflow-ruby-test-site.webflow.io'

class WebflowTest < Minitest::Test
  def test_it_fetches_sites
    VCR.use_cassette('test_it_fetches_sites') do
      assert_equal(SITE_ID, client.sites.first['_id'])
    end
  end

  def test_it_publishes_sites
    VCR.use_cassette('test_it_publishes_sites') do
      assert_equal({"queued"=>true}, client.publish(SITE_ID, domain_names: [DOMAIN]))
    end
  end

  def test_it_fetches_collections
    VCR.use_cassette('test_it_fetches_collections') do
      assert_equal COLLECTION_ID, client.collections(SITE_ID).first['_id']
    end
  end

  def test_it_creates_and_updates_items
    VCR.use_cassette('test_it_creates_and_updates_items') do
      name = "Test Item Name ABC"
      data = {
        _archived:  false,
        _draft:     false,
        name:       name,
      }
      item = client.create_item(COLLECTION_ID, data)
      assert_equal(name, item['name'])

      name = "Test Item Name Update DEF"
      item = client.update_item(item, name: name)
      assert_equal(name, item['name'])
    end
  end

  def test_it_lists_and_deletes_items
    VCR.use_cassette('test_it_lists_and_deletes_items') do
      items = client.items(COLLECTION_ID)
      items.each do |item|
        result = client.delete_item(item)
        assert_equal({"deleted"=>1}, result)
      end
    end
  end

  def client
    @client ||= Webflow::Client.new(TEST_API_TOKEN)
  end
end
