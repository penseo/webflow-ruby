require 'net/http'
require 'json'

module Webflow
  class Client
    HOST = 'https://api.webflow.com/v2'.freeze
    PAGINATION_LIMIT = 100

    def initialize(token = Webflow.config.api_token)
      @token = token
    end

    def sites
      get('/sites').fetch(:sites)
    end

    def site(site_id)
      get("/sites/#{site_id}")
    end

    def publish(site_id)
      custom_domains = site(site_id).fetch(:customDomains).map { |domain| domain[:id] }
      post("/sites/#{site_id}/publish", { publishToWebflowSubdomain: true, customDomains: custom_domains })
    end

    def collections(site_id)
      get("/sites/#{site_id}/collections").fetch(:collections)
    end

    def collection(collection_id)
      get("/collections/#{collection_id}")
    end

    # https://developers.webflow.com/reference/list-collection-items
    #
    # {
    #   items: [] your list of items returned,
    #   pagination: {
    #     limit:  the limit specified in the request (default: 100),
    #     offset: the offset specified for pagination (default: 0),
    #     total:  total # of items in the collection
    #   }
    # }
    def list_items(collection_id, limit: PAGINATION_LIMIT, offset: 0)
      limit = [limit, PAGINATION_LIMIT].min
      get("/collections/#{collection_id}/items", { limit: limit, offset: offset }).fetch(:items)
    end

    def list_all_items(collection_id) # rubocop:disable Metrics/MethodLength
      fetched_items = []
      offset = 0

      loop do
        response = get("/collections/#{collection_id}/items", { limit: PAGINATION_LIMIT, offset: offset })
        items = response.fetch(:items)

        if block_given?
          yield(items)
        else
          fetched_items.concat(items)
        end

        offset += PAGINATION_LIMIT
        break if offset >= response.dig(:pagination, :total)
      end

      fetched_items
    end

    def get_item(collection_id, item_id)
      get("/collections/#{collection_id}/items/#{item_id}")
    end

    def create_item(collection_id, data)
      result = post("/collections/#{collection_id}/items", { isArchived: false, isDraft: false, fieldData: data })
      publish_item(collection_id, result.fetch(:id))
      result
    end

    def update_item(collection_id, item_id, data)
      result = patch("/collections/#{collection_id}/items/#{item_id}", { isArchived: false, isDraft: false, fieldData: data }.compact)
      publish_item(collection_id, item_id)
      result
    end

    def delete_item(collection_id, item_id)
      # deleting items from Webflow doesn't work as expected.
      # if we delete without archiving, the item will stay visible on the site until the site is published
      # if we first archive + publish item, the item will be set as archived and not visible on the site
      # then we call delete to remove the item from Webflow CMS
      patch("/collections/#{collection_id}/items/#{item_id}", { isArchived: true, isDraft: false })
      publish_item(collection_id, item_id)
      delete("/collections/#{collection_id}/items/#{item_id}")
    end

    private

    def publish_item(collection_id, item_id)
      post("/collections/#{collection_id}/items/publish", { itemIds: Array(item_id) })
    end

    def get(path, data = nil)
      request(path, method: :get, data: data)
    end

    def post(path, data)
      request(path, method: :post, data: data)
    end

    def patch(path, data)
      request(path, method: :patch, data: data)
    end

    def delete(path)
      request(path, method: :delete)
    end

    def request(path, method:, data: nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      url = URI.parse(HOST + path)
      bearer = "Bearer #{@token}"
      headers = { accept: 'application/json', 'content-type': 'application/json', authorization: bearer }
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'

      url.query = URI.encode_www_form(data) if data && method == :get

      request_class = { get: Net::HTTP::Get, post: Net::HTTP::Post, patch: Net::HTTP::Patch, delete: Net::HTTP::Delete }.fetch(method)
      request = request_class.new(url.to_s, headers)
      request.body = data.to_json if %i[post patch].include?(method)

      response = http.request(request)
      body = response.read_body

      result = JSON.parse(body, symbolize_names: true) unless body.nil?
      raise Webflow::Error, result if response.code.to_i >= 400

      result
    end
  end
end
