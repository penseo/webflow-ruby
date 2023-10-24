require 'http'

module Webflow
  class Client
    HOST = 'https://api.webflow.com/v2'

    def initialize(token = nil)
      @token = token || Webflow.config.api_token
      @rate_limit = {}
    end

    def rate_limit
      @rate_limit || {}
    end

    def limit
      rate_limit['X-Ratelimit-Limit'].to_i
    end

    def remaining
      rate_limit['X-Ratelimit-Remaining'].to_i
    end

    def sites
      get('/sites')
    end

    def site(site_id)
      get("/sites/#{site_id}")
    end

    def domains(site_id)
      get("/sites/#{site_id}/custom_domains")
    end

    def publish(site_id, custom_domains: nil)
      custom_domains ||= domains(site_id).map { |domain| domain['name'] }
      post("/sites/#{site_id}/publish", { publishToWebflowSubdomain: true, customDomains: custom_domains })
    end

    def collections(site_id)
      get("/sites/#{site_id}/collections")
    end

    def collection(collection_id)
      get("/collections/#{collection_id}")
    end

    # https://developers.webflow.com/?javascript#get-all-items-for-a-collection
    # returns json object with data to help paginate collection
    #
    # {
    #   items: [] your list of items returned,
    #   pagination: {
    #     limit:  the limit specified in the request (default: 100),
    #     offset: the offset specified for pagination (default: 0),
    #     total:  total # of items in the collection
    #   }
    # }
    #
    # page starts at 1
    def paginate_items(collection_id, per_page: 100, page: 1)
      get("/collections/#{collection_id}/items", params: { limit: per_page, offset: per_page * (page - 1) })
    end

    def items(collection_id, limit: 100)
      fetched_items = []
      num_pages     = (limit.to_f / 100.0).ceil
      per_page      = limit > 100 ? 100 : limit

      num_pages.times do |i|
        response = paginate_items(collection_id, per_page: per_page, page: i + 1)
        items = response.fetch('items')

        if block_given?
          yield(items)
        else
          fetched_items += items
        end
      end

      fetched_items
    end

    def item(collection_id, item_id)
      get("/collections/#{collection_id}/items/#{item_id}")
    end

    def create_item(collection_id, data, is_archived: false, is_draft: false, publish: false)
      result = post("/collections/#{collection_id}/items",
                    { isArchived: is_archived, isDraft: is_draft, fieldData: data })
      return result unless publish

      publish_item(collection_id, result.fetch('id'))
      result
    end

    def update_item(collection_id, item_id, data, is_archived: false, is_draft: false, publish: false)
      result = patch("/collections/#{collection_id}/items/#{item_id}",
                     { isArchived: is_archived, isDraft: is_draft, fieldData: data })
      return result unless publish

      publish_item(collection_id, item_id)
      result
    end

    def delete_item(collection_id, item_id)
      delete("/collections/#{collection_id}/items/#{item_id}")
    end

    def publish_item(collection_id, item_id)
      publish_items(collection_id, Array.wrap(item_id))
    end

    def publish_items(collection_id, item_ids)
      post("/collections/#{collection_id}/items/publish", { itemIds: item_ids })
    end

    private

    def get(path, params: nil)
      request(path, method: :get, params: params)
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

    def request(path, method: :get, params: nil, data: nil)
      url = URI.parse(HOST + path)
      bearer = "Bearer #{@token}"
      headers = { 'accept': 'application/json', 'content-type': 'application/json' }

      response = HTTP.auth(bearer).headers(headers).request(method, url, params: params, json: data)

      track_rate_limit(response.headers)

      result = JSON.parse(response.body) unless response.body.empty?
      raise Webflow::Error, result if response.code >= 400

      result
    end

    def track_rate_limit(headers)
      rate_limit = headers.select { |key, _value| key =~ /X-Ratelimit/ }.to_h
      @rate_limit = rate_limit unless rate_limit.empty?
    end
  end
end
