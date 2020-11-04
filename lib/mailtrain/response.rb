require 'json'

module Mailtrain
  class Response
    def initialize(json)
      @res = symbolize_keys(JSON.parse(json))
    end

    def success?
      @res[:error].nil?
    end

    def error_message
      @res[:error]
    end

    def data
      @res[:data]
    end

    protected

    def symbolize_keys(hash)
      hash.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value.is_a?(Hash) ? symbolize_keys(value) : value
        options
      end
    end

  end
end