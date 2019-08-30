module Webflow
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end

  class Config
    attr_accessor :api_token
  end
end
