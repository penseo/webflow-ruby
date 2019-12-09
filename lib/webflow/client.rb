require 'http'

module Webflow
  class Client
    HOST = 'https://api.webflow.com'

    def initialize(token = nil)
      @token = token || Webflow.config.api_token
      @rate_limit = {}
    end

    def rate_limit
      @rate_limit
    end

    def info
      get("/info")
    end

    def sites
      get("/sites")
    end

    def site(site_id)
      get("/sites/#{site_id}")
    end

    def domains(site_id)
      get("/sites/#{site_id}/domains")
    end

    def publish(site_id, domain_names: nil)
      domain_names ||= domains(site_id).map { |domain| domain['name'] }
      post("/sites/#{site_id}/publish", domains: domain_names)
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
    #   items:  your list of items returned,
    #   count:  number of items returned,
    #   limit:  the limit specified in the request (default: 100),
    #   offset: the offset specified for pagination (default: 0),
    #   total:  total # of items in the collection
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
        resp = paginate_items(collection_id, per_page: per_page, page: i+1)
        fetched_items += resp['items']
        limit -= resp['count']
        break if limit <= 0 || resp['total'] <= fetched_items.length
      end

      fetched_items
    end

    def item(collection_id, item_id)
      json = get("/collections/#{collection_id}/items/#{item_id}")
      json['items'].first
    end

    def create_item(collection_id, data, live: false)
      post("/collections/#{collection_id}/items", {fields: data}, live: live)
    end

    def update_item(item, data, live: false)
      # FIXME: (PS) looks like the API does not have partial updates...
      base = item.reject {|key, _| ['_id', 'published-by', 'published-on', 'created-on', 'created-by', 'updated-by', 'updated-on', '_cid'].include?(key) }
      put("/collections/#{item['_cid']}/items/#{item['_id']}", {fields: base.merge(data)}, live: live)
    end

    def delete_item(item)
      delete("/collections/#{item['_cid']}/items/#{item['_id']}")
    end

    private

    def get(path, params: nil)
      request(path, method: :get, params: params)
    end

    def post(path, data, live: nil)
      params = { live: 'true' } if live
      request(path, method: :post, params: params, data: data)
    end

    def put(path, data, live: nil)
      params = { live: 'true' } if live
      request(path, method: :put, params: params, data: data)
    end

    def delete(path)
      request(path, method: :delete)
    end

    def request(path, method: :get, params: nil, data: nil)
      url = URI.join(HOST, path)
      bearer = "Bearer #{@token}"
      headers = {'Accept-Version' => '1.0.0'}

      response = HTTP.auth(bearer).headers(headers).request(method, url, params: params, json: data)

      track_rate_limit(response.headers)

      result = JSON.parse(response.body)
      raise Webflow::Error.new(result) if response.code >= 400

      result
    end

    def track_rate_limit(headers)
      rate_limit = headers.select { |key, value| key =~ /X-Ratelimit/ }.to_h
      @rate_limit = rate_limit unless rate_limit.empty?
    end
  end
end
