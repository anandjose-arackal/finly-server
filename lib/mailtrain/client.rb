require 'faraday'
require 'json'
require 'mailtrain/response'

module Mailtrain
  class Client

    def initialize(host_url, access_token = nil)
      @url = host_url
      @access_token = access_token || ENV['MAILTRAIN_ACCESS_TOKEN']
      @response = nil
    end

    # Add subscription
    def subscribe(list_id, email: , timezone: nil, force_subscribe: true, merge_attributes: {})
      request_body = {email: email, timezone: timezone, force_subscribe: force_subscribe}.select { |_, value| !value.nil? }
      merge_attributes.each do |key, value|
        request_body["merge_#{key}"] = value
      end
      puts "Request Body: #{request_body}"
      response = request :post, "/api/subscribe/#{list_id}", request_body

      @response = Response.new response.body
      success?
    end

    def unsubscribe(list_id, email)
      response = request :post, "/api/unsubscribe/#{list_id}", {list: list_id, email: email}

      @response = Response.new response.body
      success?
    end

    # Get list of blacklisted emails
    def blacklist(start = 0, limit = 10000, search = '')
      response = request :get, "/api/blacklist/get&start=#{start}&limit=#{limit}&search=#{search}"

      @response = Response.new response.body
      data
    end

    # Add email to blacklist
    def block(email)
      response = request :post, "/api/blacklist/add", {email: email}

      @response = Response.new response.body
      success?
    end

    # delete email to blacklist
    def unblock(email)
      response = request :post, "/api/blacklist/delete", {email: email}

      @response = Response.new response.body
      success?
    end

    def success?
      @response.respond_to?(:success?) ? @response.success? : false
    end

    def error
      @response.error_message
    end

    def data
      @response.data
    end

    protected

    def request(method, path, body = {})
      connection.send method, path do |request|
        request.headers['Content-Type'] = 'application/json'
        request.params = {access_token: @access_token}
        request.body = body.to_json if body.present?
      end
    end

    def connection
      @connection ||= Faraday.new(:url => @url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        # faraday.adapter  :excon
      end
    end

  end
end