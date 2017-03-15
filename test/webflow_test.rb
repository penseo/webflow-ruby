require 'test_helper'

TEST_API_TOKEN = 'c39d97f0ff14af5824b85c660e9cb86e59a6156c3209a491ace867477e9252e6'
SITE_ID = '58c996aa4e6fd9182228b630'
COLLECTION_ID = '58c996f626822cec4614519d'
DOMAIN = 'rubys-first-project.webflow.io'

class WebflowTest < Minitest::Test
  def test_it_fetches_sites
    assert_equal(SITE_ID, client.sites.first['_id'])
  end

  def test_it_publishes_sites
    assert_equal({"queued"=>true}, client.publish(SITE_ID, domain_names: [DOMAIN]))
  end

  def test_it_fetches_collections
    assert_equal COLLECTION_ID, client.collections(SITE_ID).first['_id']
  end

  def test_it_creates_and_updates_items
    name = "Test Item Name #{Time.now}"
    data = {
      _archived:  false,
      _draft:     false,
      name:       name,
    }
    item = client.create_item(COLLECTION_ID, data)
    assert_equal(name, item['name'])

    name = "Test Item Name Update #{Time.now}"
    item = client.update_item(COLLECTION_ID, item, name: name)
    assert_equal(name, item['name'])
  end

  def test_it_lists_and_deletes_items
    items = client.items(COLLECTION_ID)
    items.each do |item|
      result = client.delete_item(COLLECTION_ID, item['_id'])
      assert_equal({"deleted"=>1}, result)
    end
  end

  def client
    @client ||= Webflow::Client.new(TEST_API_TOKEN)
  end
end
