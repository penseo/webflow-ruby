require 'test_helper'

SITE_ID = '655276a1c36e738ce983a307'.freeze
COLLECTION_ID = '655276efe9424bcefd3231a2'.freeze
CLIENT = Webflow::Client.new(ENV.fetch('TEST_API_TOKEN'))

class WebflowTest < Minitest::Test
  def test_it_fetches_sites
    VCR.use_cassette('test_it_fetches_sites') do
      assert_equal(SITE_ID, CLIENT.sites.first.fetch(:id))
    end
  end

  def test_it_publishes_sites
    VCR.use_cassette('test_it_publishes_sites') do
      assert_equal({ customDomains: [], publishToWebflowSubdomain: true }, CLIENT.publish(SITE_ID))
    end
  end

  def test_it_fetches_collections
    VCR.use_cassette('test_it_fetches_collections') do
      assert_equal COLLECTION_ID, CLIENT.collections(SITE_ID).first.fetch(:id)
    end
  end

  def test_it_fetches_a_single_collection
    VCR.use_cassette('test_it_fetches_single_collection') do
      assert_equal COLLECTION_ID, CLIENT.collection(COLLECTION_ID).fetch(:id)
    end
  end

  def test_it_creates_and_updates_items
    VCR.use_cassette('test_it_creates_and_updates_items') do
      name = 'Test Item Name ABC'
      data = { name: name }
      item = CLIENT.create_item(COLLECTION_ID, data)

      assert_equal(name, item.dig(:fieldData, :name))

      name = 'Test Item Name Update DEF'
      item = CLIENT.update_item(COLLECTION_ID, item.fetch(:id), { name: name })

      assert_equal(name, item.dig(:fieldData, :name))
    end
  end

  def test_it_creates_and_updates_items_with_publish
    VCR.use_cassette('test_it_creates_and_updates_items_with_publish') do
      name = 'Test Item Name ABC LIVE'
      data = { name: name }

      item = CLIENT.create_item(COLLECTION_ID, data, publish: true)

      assert_equal(name, item.dig(:fieldData, :name))

      name = 'Test Item Name Update DEF LIVE'

      item = CLIENT.update_item(COLLECTION_ID, item.fetch(:id), { name: name }, publish: true)

      assert_equal(name, item.dig(:fieldData, :name))
    end
  end

  def test_it_fetches_a_single_item
    VCR.use_cassette('test_it_fetches_a_single_item') do
      data = { name: 'Test Item Name ABC' }
      item = CLIENT.create_item(COLLECTION_ID, data)

      assert_equal item.fetch(:id), CLIENT.item(COLLECTION_ID, item.fetch(:id)).fetch(:id)
    end
  end

  def test_it_raises_validation_errors # rubocop:disable Metrics/MethodLength
    VCR.use_cassette('test_it_raises_validation_errors') do
      data = { unknown: 'this raises an error' }
      begin
        CLIENT.create_item(COLLECTION_ID, data)

        flunk('should have raised')
      rescue StandardError => e
        error = {
          message: %{Validation Error: ["Value (fieldData) should have required property 'name'"]}, code: 'validation_error',
          externalReference: nil, details: []
        }

        assert_equal(error, e.data)
      end
    end
  end

  def test_it_raises_validation_errors_with_problems
    VCR.use_cassette('test_raises_validation_errors_with_problems') do
      data = { name: 'SomeName', field_with_validation: "sh\nrt" }
      begin
        CLIENT.create_item(COLLECTION_ID, data)

        flunk('should have raised')
      rescue StandardError => e
        details = 'Validation Error: [{:param=>"field_with_validation", :description=>"Field not described in schema: undefined"}]'

        assert_equal(details, e.message)
      end
    end
  end

  def test_it_paginates_items # rubocop:disable Metrics/MethodLength
    VCR.use_cassette('test_it_paginates_items') do
      names = ['Test 1', 'Test 2', 'Test 3', 'Test 4']
      names.each do |name|
        CLIENT.create_item(COLLECTION_ID, { name: name })
      end

      page_one = CLIENT.paginate_items(COLLECTION_ID, per_page: 2, page: 1)

      assert_equal(2, page_one.dig(:pagination, :limit))
      page_two = CLIENT.paginate_items(COLLECTION_ID, per_page: 2, page: 2)

      assert_equal(2, page_two.dig(:pagination, :limit))
      refute_equal(page_one.fetch(:items), page_two.fetch(:items))
    end
  end

  def test_it_yields_items_when_a_block_is_given
    VCR.use_cassette('test_it_paginates_items') do
      names = ['Test 1', 'Test 2', 'Test 3', 'Test 4']
      names.each do |name|
        CLIENT.create_item(COLLECTION_ID, { name: name })
      end

      limit = 3

      CLIENT.items(COLLECTION_ID, limit: limit) do |items|
        assert_equal(items.length, limit)
      end
    end
  end

  def test_it_lists_and_deletes_items # rubocop:disable Metrics/MethodLength
    VCR.use_cassette('test_it_lists_and_deletes_items') do
      names = ['To delete Test 1', 'To delete Test 2']
      names.each do |name|
        CLIENT.create_item(COLLECTION_ID, { name: name })
      end
      items = CLIENT.items(COLLECTION_ID)
      items.each do |item|
        next unless item.dig(:fieldData, :name).start_with?('To delete')

        result = CLIENT.delete_item(COLLECTION_ID, item.fetch(:id))

        assert_nil(result)
      end
    end
  end

  def test_it_tracks_rate_limits # rubocop:disable Metrics/MethodLength, Minitest/MultipleAssertions
    VCR.use_cassette('test_it_tracks_rate_limits') do
      CLIENT.collections(SITE_ID)
      limit = { 'X-Ratelimit-Limit' => '60', 'X-Ratelimit-Remaining' => '59' }

      assert_equal(limit, CLIENT.rate_limit)
      assert_equal(60, CLIENT.limit)
      assert_equal(59, CLIENT.remaining)

      CLIENT.collections(SITE_ID)
      limit = { 'X-Ratelimit-Limit' => '60', 'X-Ratelimit-Remaining' => '58' }

      assert_equal(limit, CLIENT.rate_limit)
      assert_equal(60, CLIENT.limit)
      assert_equal(58, CLIENT.remaining)
    end
  end

  def test_it_raises_rate_limit_error
    VCR.use_cassette('test_it_raises_rate_limit_error') do
      error = assert_raises Webflow::Error do
        CLIENT.collections(SITE_ID)
      end

      assert_equal('Too Many Requests', error.message)
    end
  end
end
