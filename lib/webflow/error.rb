module Webflow
  class Error < StandardError
    # https://developers.webflow.com/#errors
    # 400 	SyntaxError 	Request body was incorrectly formatted. Likely invalid JSON being sent up.
    # 400 	InvalidAPIVersion 	Requested an invalid API version
    # 400 	UnsupportedVersion 	Requested an API version that in unsupported by the requested route
    # 400 	NotImplemented 	This feature is not currently implemented
    # 400 	ValidationError 	Validation failure (see problems field in the response)
    # 400 	Conflict 	Request has a conflict with existing data.
    # 401 	Unauthorized 	Provided access token is invalid or does not have access to requested resource
    # 404 	NotFound 	Requested resource not found
    # 429 	RateLimit 	The rate limit of the provided access_token has been reached. Please have your application respect the X-RateLimit-Remaining header we include on API responses.
    # 500 	ServerError 	We had a problem with our server. Try again later.
    # 400 	UnknownError 	An error occurred which is not enumerated here, but is not a server error.
    #
    # Sample error response
    #
    # {
    #   "msg": "Cannot access resource",
    #   "code": 401,
    #   "name": "Unauthorized",
    #   "path": "/sites/invalid_site",
    #   "err": "Unauthorized: Cannot access resource"
    # }

    attr_reader :data

    def initialize(data)
      @data = data

      error_message = <<~END_OF_ERROR
        #{data['msg']}
        #{(data['problems'] || []).join("\n")}
      END_OF_ERROR

      super(error_message)
    end
  end
end
