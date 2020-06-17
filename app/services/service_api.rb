class ServiceApi < Transactions::API
  include Dry::Monads[:result]
  include DynamicAttributes

  attr_accessor :user, :params

  class_attr :url
  class_attr :path
  class_attr :http_method, default: :get
  class_attr :mime_type, default: 'application/json'
  class_attr :timeout, default: 60
  class_attr :open_timeout, default: 60
  class_attr :query_params, default: {}
  class_attr :headers, default: {}
  class_attr :body
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
  pass :log!
  fail :log!, id: "failure.log"

  def self.header(key, value)
    headers[key] = value
  end

  def init(options, params:, current_user:, **)
    self.params = options[:params]
    self.user = current_user
    log_generator.merge({user: self.user&.as_json, params: params, service_api: self.class.name})
    true
  end

  def validate_api(options, params:, current_user:, **)
    true
  end

  def execute(options, params:, current_user:, **)
    start_time = Time.now
    options['response'] = get_response
    end_time = Time.now
    log_generator.merge({duration: (end_time - start_time)})
    puts "Response: #{options[:response]&.body}" rescue nil
    true
  end

  def parse(options, params:, current_user:, response:, **)
    body = result = response.body
    parser = self.class.parse

    result = instance_exec(current_user, params, response, &parser) if parser.present?
    if result.is_a?(Failure)
      log_generator.merge({response: {body: response.body, status: response.status}})
      log_generator.merge({error: result.failure})
      return on_error options, :base, result.failure
    end

    # options['response.status_code'] = response.status_code
    options['response.status_code'] = response.status
    options['response.parsed'] = result
    log_generator.merge({response: {body: body, parsed: result, status: response.status}})
    true
  end

  def log!(ctx, options)
    log_generator.log!
  end

  protected

  def fetch(key)
    val = self.class.send(key)
    if val.is_a?(Proc)
      result = instance_exec self.user, self.params, &val
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
    endpoint = url + fetch(:path)
    endpoint
  end

  def get_response
    method = fetch(:http_method)
    ep = endpoint
    log_generator.merge(
        {
            method: method,
            endpoint: ep
        }
    )
    fetch(:client).send(method) do |request|
      request.url ep
      request.params = fetch(:query_params) if fetch(:query_params)
      if fetch(:body)
        request.body = fetch(:body).to_json
        log_generator.merge({request: {body: request.body}})
        puts "Body: #{request.body}"
      end
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

  def log_generator
    @log_generator ||= LogGenerator.new("services")
  end

end