require 'typhoeus'
require 'nokogiri'
require 'oj'

module Webflow
  class Client
    HOST = 'https://api.webflow.com'
    OJ_OPTIONS = {mode: :strict, nilnil: true}

    def initialize(token)
      @token = token
      @rate_limit = {}
    end

    def rate_limit
      @rate_limit
    end

    def info
      get("/info")
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

    def update_item(item, data)
      # FIXME: (PS) looks like the API does not have partial updates...
      base = item.reject {|key, _| ['_id', 'published-by', 'published-on', 'created-on', 'created-by', 'updated-by', 'updated-on', '_cid'].include?(key) }
      put("/collections/#{item['_cid']}/items/#{item['_id']}", fields: base.merge(data))
    end

    def delete_item(item)
      delete("/collections/#{item['_cid']}/items/#{item['_id']}")
    end

    private

    def get(path, params: nil)
      request(path, method: :get, params: params)
    end

    def post(path, data)
      request(path, method: :post, body: data)
    end

    def put(path, data)
      request(path, method: :put, body: data)
    end

    def delete(path)
      request(path, method: :delete)
    end

    def request(path, method: :get, params: nil, body: nil)
      body = Oj.dump(body, OJ_OPTIONS) if body
      json = http(path, method: method, params: params, headers: request_headers, body: body)
      Oj.load(json, OJ_OPTIONS)
    end

    def http(path, method: :get, params: nil, headers: nil, body: nil)
      url = File.join(HOST, path)
      request = Typhoeus::Request.new(
        url,
        method: method,
        params: params,
        headers: headers,
        body: body,
      )
      response = request.run

      track_rate_limit(response.headers)

      response.body
    end

    def track_rate_limit(headers)
      rate_limit = headers.select { |key, value| key =~ /X-Ratelimit/ }
      @rate_limit = rate_limit unless rate_limit.empty?
      # byebug
    end

    def request_headers
      {
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/json',
        'Accept-Version' => '1.0.0',
      }
    end

    def error_codes
      # https://developers.webflow.com/#errors
      {
        [400,	SyntaxError] =>	'Request body was incorrectly formatted. Likely invalid JSON being sent up.',
        [400,	InvalidAPIVersion] =>	'Requested an invalid API version',
        [400,	UnsupportedVersion] =>	'Requested an API version that in unsupported by the requested route',
        [400,	NotImplemented] =>	'This feature is not currently implemented',
        [400,	ValidationError] =>	'Validation failure (see problems field in the response)',
        [400,	Conflict] =>	'Request has a conflict with existing data.',
        [401,	Unauthorized] =>	'Provided access token is invalid or does not have access to requested resource',
        [404,	NotFound] =>	'Requested resource not found',
        [429,	RateLimit] =>	'The rate limit of the provided access_token has been reached. Please have your application respect the X-RateLimit-Remaining header we include on API responses.',
        [500,	ServerError] =>	'We had a problem with our server. Try again later.',
        [400,	UnknownError] =>	'An error occurred which is not enumerated here, but is not a server error.',
      }
    end
  end
end
