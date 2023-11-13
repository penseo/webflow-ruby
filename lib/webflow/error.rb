module Webflow
  class Error < StandardError
    attr_reader :data

    def initialize(data)
      @data = data

      message = "#{data[:message]}#{": #{Array(details)}" if details?}"
      super(message)
    end

    def details?
      details && !details.empty?
    end

    def details
      data[:details]
    end
  end
end
