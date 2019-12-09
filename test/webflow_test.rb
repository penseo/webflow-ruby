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

  def test_it_fetches_a_single_collection
    VCR.use_cassette('test_it_fetches_single_collection') do
      assert_equal COLLECTION_ID, client.collection(COLLECTION_ID)['_id']
    end
  end

  def test_it_creates_and_updates_items
    VCR.use_cassette('test_it_creates_and_updates_items') do
      name = 'Test Item Name ABC'
      data = {
        _archived:  false,
        _draft:     false,
        name:       name,
      }
      item = client.create_item(COLLECTION_ID, data)
      assert_equal(name, item['name'])

      name = 'Test Item Name Update DEF'
      item = client.update_item(item, name: name)
      assert_equal(name, item['name'])
    end
  end

  def test_it_fetches_a_single_item
    VCR.use_cassette('test_it_fetches_a_single_item') do
      data = {
        _archived:  false,
        _draft:     false,
        name:       'Test Item Name ABC',
      }
      item = client.create_item(COLLECTION_ID, data)
      assert_equal item['_id'], client.item(COLLECTION_ID, item['_id'])['_id']
    end
  end

  def test_handles_raises_validation_errors
    VCR.use_cassette('test_handles_errors_gracefully') do
      data = {
        _archived:  false,
        _draft:     false,
        unknown:    'this raises an error',
      }
      begin
        client.create_item(COLLECTION_ID, data)
      rescue => err
        error = {"msg"=>"'fields.name' is required", "code"=>400, "name"=>"ValidationError", "path"=>"/collections/58c9a554a118f71a388bcc89/items", "err"=>"ValidationError: 'fields.name' is required"}
        assert_equal(error, err.data)
      end
    end
  end

  def test_it_paginates_items
    VCR.use_cassette('test_it_paginates_items') do
      names = ['Test 1', 'Test 2', 'Test 3', 'Test 4']
      names.each do |name|
        client.create_item(COLLECTION_ID, { name: name, _archived: false, _draft: false })
      end


      page_one = client.paginate_items(COLLECTION_ID, per_page: 2, page: 1)
      assert_equal(page_one['count'], 2)
      page_two = client.paginate_items(COLLECTION_ID, per_page: 2, page: 2)
      assert_equal(page_two['count'], 2)
      assert_equal((page_one['items'] == page_two['items']), false)
    end
  end

  def test_it_yields_items_when_a_block_is_given
    VCR.use_cassette('test_it_paginates_items') do
      names = ['Test 1', 'Test 2', 'Test 3', 'Test 4']
      names.each do |name|
        client.create_item(COLLECTION_ID, { name: name, _archived: false, _draft: false })
      end

      limit = 3
      client.items(COLLECTION_ID, limit: limit) do |items|
        assert_equal(client.limit, 60)
        assert_equal(client.remaining, 60)
        assert_equal(items.length, limit)
      end
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

  def test_it_respects_items_limit
    VCR.use_cassette('test_it_paginates_items') do
      names = ['Test 1', 'Test 2', 'Test 3', 'Test 4']
      names.each do |name|
        client.create_item(COLLECTION_ID, { name: name, _archived: false, _draft: false })
      end

      limit = 3
      items = client.items(COLLECTION_ID, limit: 3)
      assert_equal(items.length, limit)
    end
  end

  def test_it_tracks_rate_limits
    VCR.use_cassette('test_it_tracks_rate_limits') do
      client.collections(SITE_ID)
      limit = {"X-Ratelimit-Limit"=>"60", "X-Ratelimit-Remaining"=>"41"}
      assert_equal(limit, client.rate_limit)

      client.collections(SITE_ID)
      limit = {"X-Ratelimit-Limit"=>"60", "X-Ratelimit-Remaining"=>"40"}
      assert_equal(limit, client.rate_limit)
    end
  end

  def test_it_raises_rate_limit_error
    VCR.use_cassette('test_it_raises_rate_limit_error') do
      assert_raises Webflow::Error do
        client.collections(SITE_ID)
      end
    end
  end

  def client
    @client ||= Webflow::Client.new(TEST_API_TOKEN)
  end
end
