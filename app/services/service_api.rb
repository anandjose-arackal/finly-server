class ServiceApi < Transactions::API
  include DynamicAttributes

  attr_accessor :user, :params

  class_attr :url
  class_attr :path
  class_attr :http_method, default: 'get'
  class_attr :mime_type, default: 'application/json'
  class_attr :timeout, default: 5
  class_attr :open_timeout, default: 2
  class_attr :query_params, default: {}
  class_attr :headers, default: {}
  class_attr :body
  class_attr :matchers, default: {}
  class_attr :parse
  class_attr :client, default: -> (user, params) do
    Faraday.new(url: self.class.url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  step :init
  step :validate_api
  step :execute
  step :parse

  def self.matcher(key, match:, resolve:)
    matchers[key] = Dry::Matcher::Case.new({match: match, resolve: resolve})
  end

  def self.header(key, value)
    headers[key] = value
  end

  def self.call(options = {}, *dependencies, &handlers)
    result = super(options, *dependencies)
    if block_given?
      @dry_matcher ||= Dry::Matcher.new(matchers)
      @dry_matcher.(result, &handlers)
    end
    result
  end

  def init(options, params:, current_user:, **)
    @params = params
    @current_user = current_user
    true
  end

  def validate_api(options, params:, current_user:, **)
    true
  end

  def execute(options, params:, current_user:, **)
    options['response'] = get_response
    true
  end

  def parse(options, params:, current_user:, response:, **)
    parser = self.class.parse
    return options['result'] = parser.call(current_user, params, response) if parser.present?

    options['result'] = response.body
    true
  end

  protected

  def fetch(key)
    val = self.class.send(key)
    if val.is_a?(Proc)
      result = instance_exec @user, @params, &val
    else
      result = val
    end
    return result if result.present?
    return result unless required_data.include?(key)

    raise "#{key} is not defined for #{self.class.name}"
  end

  def endpoint
    url = fetch(:url)
    url += "/" unless url.blank? or url.ends_with?("/")
    url + fetch(:path)
  end

  def get_response
    fetch(:client).send(fetch(:http_method)) do |request|
      request.url endpoint
      request.params = fetch(:query_params) if fetch(:query_params)
      request.body = fetch(:body).to_json if fetch(:body)
      request.options.timeout = fetch(:timeout)
      request.options.open_timeout = fetch(:open_timeout)
      request.headers['Accept'] = fetch(:mime_type)
      request.headers['Content-Type'] = fetch(:mime_type)
      fetch(:headers).each do |header, value|
        request.headers[header] = value
      end
    end
  end

  def required_data
    [:http_method, :url, :path, :client]
  end

  # def execute(options, params:, current_user:, **)
  #   # return unless valid_params?
  #   options['response'] = get_response(current_user, params)
  #   result = parse(response)
  #
  #   @dry_matcher ||= Dry::Matcher.new(matchers)
  #   @dry_matcher.({response: response, result: result}, handler)
  # end

  # http_method :get
  # path 'billers_api'
  # mime_type 'application/json'
  # timeout 5
  # open_timeout 2
  # query_params -> (user, params){{a: 1}}
  # authorization username: "", password: ""
  # body -> (user, params){ params[:body] }
  # client :bbps_client

  # matcher :success, match: -> () {}, resolve: -> () {}
  # matcher :failure, match: -> () {}, resolve: -> () {}
  # matcher :unauthorized, match: -> () {}, resolve: -> () {}

  # matcher(
  #     {
  #         success: {
  #             match: -> (user, params, response) {},
  #             resolve: -> (user, params, response) {}
  #         },
  #         failure: {
  #             match: -> (user, params, response) {},
  #             resolve: -> (user, params, response) {}
  #         },
  #         unauthorized: {
  #             match: -> (user, params, response) {},
  #             resolve: -> (user, params, response) {}
  #         },
  #     }
  # )


  # def initialize(url:, timeout: 5, open_timeout: 2, mime_type: 'application/json')
  #   @url          = url
  #   @timeout      = timeout
  #   @open_timeout = open_timeout
  #   @mime_type    = mime_type
  # end
  #
  # def call(path:, method: :get, query: nil, body: nil, headers: {})
  #   request = request(path, query: query, body: body, headers: headers)
  #   response = connection.send(method, &request)
  #   Response.new(response)
  # end
  #
  # private
  #
  # def request(path, query: nil, body: nil, headers: {})
  #   lambda do |request|
  #     request.url path
  #     request.params = query if query
  #     request.body = body.to_json if body
  #     request.options.timeout = @timeout
  #     request.options.open_timeout = @open_timeout
  #     request.headers['Accept'] = @mime_type
  #     request.headers['Content-Type'] = @mime_type
  #     headers.each { |header, value| request.headers[header] = value }
  #   end
  # end
  #
  # def connection
  #   @connection ||= Faraday.new(url: @url) do |faraday|
  #     faraday.request :url_encoded
  #     faraday.adapter Faraday.default_adapter
  #   end
  # end
end