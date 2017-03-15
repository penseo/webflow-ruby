require 'typhoeus'
require 'nokogiri'
require 'oj'

module Webflow
  class Client
    HOST = 'https://api.webflow.com'

    def initialize(token)
      @token = token
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

    def items(collection_id, limit: 100)
      json = get("/collections/#{collection_id}/items", params: {limit: limit})
      json['items']
    end

    def create_item(collection_id, data)
      post("/collections/#{collection_id}/items", fields: data)
    end

    def update_item(collection_id, item, data)
      # FIXME: (PS) looks like the API does not have partial updates...
      base = item.reject {|key, _| ['_id', 'published-by', 'published-on', 'created-on', 'created-by', 'updated-by', 'updated-on', '_cid'].include?(key) }
      put("/collections/#{collection_id}/items/#{item['_id']}", fields: base.merge(data))
    end

    def delete_item(collection_id, item_id)
      delete("/collections/#{collection_id}/items/#{item_id}")
    end

    private

    def get(path, params: nil)
      http(path, method: :get, headers: headers, params: params)
    end

    def post(path, data)
      http(path, method: :post, headers: headers, body: data)
    end

    def put(path, data)
      http(path, method: :put, headers: headers, body: data)
    end

    def delete(path)
      http(path, method: :delete, headers: headers)
    end

    def http(path, method: :get, params: nil, headers: nil, body: nil)
      url = File.join(HOST, path)
      request = Typhoeus::Request.new(
        url,
        method: method,
        params: params,
        headers: headers,
        body: (Oj.dump(body) if body),
      )
      body = request.run.body
      Oj.load(body)
    end

    def headers
      {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json',
        'accept-version' => '1.0.0',
      }
    end
  end
end
