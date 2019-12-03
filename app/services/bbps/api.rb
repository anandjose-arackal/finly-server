class Bbps::Api < ServiceApi

  # Matcher = Dry::Matcher.new(
  #     success: Dry::Matcher::Case.new(
  #         match: -> (result) { result['response.parsed']&.dig(:status) == 'Y' },
  #         resolve: -> (result) { handle_success(result) }
  #     ),
  #     failure: Dry::Matcher::Case.new(
  #         match: -> (result) { true },
  #         resolve: -> (result) { result['response.parsed'] }
  #     )
  # )

  class_attr :dummy_response
  class_attr :request_fields, default: []
  class_attr :response_fields, default: []
  class_attr :success_object
  skip_user_authorization!
  http_method :post
  mime_type "application/json"
  url "https://uatsky.yesbank.in:444/app/uat/bbps"
  header 'X-IBM-Client-Id', "9e10ff7b-3141-4b0c-aa56-d110148c0fe7"
  header 'X-IBM-Client-Secret', "cK7bT1nN7eK2gQ0vS2cT4uI0oP7mN7dB2tG4tN3jB0sY2uQ2mW"
  body -> (user, params) { body }
  client -> (user, params) { client }
  parse -> (user, params, response) { parse_response(user, params, response) }
  matcher Dry::Matcher.new(
    success: Dry::Matcher::Case.new(
      match: -> (result) { result['response.parsed']&.dig(:status) == 'Y' },
      resolve: -> (result) { handle_success(result) }
    ),
    failure: Dry::Matcher::Case.new(
      match: -> (result) { true },
      resolve: -> (result) { result.errors }
    )
  )

  def body
    message = generate_message
    body = {requestMsg: encrypt(message), agentInstitutionId: agent_institution_id}
    puts "Message: #{message}"
    puts "Body: #{body}"
    body
  end

  def generate_message
    req = []
    fetch(:request_fields).each do |field|
      val = (self.respond_to?(field) ? self.send(field) : nil)
      req << (val.present? ? val : "NA")
    end
    req.join("|")
  end

  # Todo load from YAML
  def encryption_key
    '4d5390bef3ef1ee3d4a7e77fd42238cb'
  end

  def encrypt(message)
    result = nil
    Open3.popen3("java UPISecurity.java \"#{message}\" \"#{encryption_key}\"") do |stdin, stdout, strerr|
      result = stdout.read
    end
    result
  end

  # Map the response splits with the respective headers provided by response_fields
  def parse_response(user, params, response)
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    # Request failed
    return Failure((splits[3] || "Unable to fetch response")) if splits[1] == "N"

    map = {}.with_indifferent_access
    fetch(:response_fields).each_with_index { |field, index| map[field] = splits[index] }
    map
  end

  # The JSON response has a pipe delimiter in the biller_details. Hence, handling it correctly
  def parse_json_response(json_key, user, params, response)
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    # Request failed
    return Failure((splits[3] || "Unable to fetch response")) if splits[1] == "N"

    map = {}.with_indifferent_access

    # Map till channel id
    response_fields = fetch(:response_fields)
    json_key_index = response_fields.find_index(json_key)
    start_index = json_key_index
    end_index = splits.size - (response_fields.size - json_key_index)
    # 0 to json_key
    response_fields.first(start_index).each_with_index { |field, index| map[field] = splits[index] }

    # Json key
    map[json_key] = splits[start_index..end_index].join("|")

    # JSON Key to end
    ending_splits = splits.last(end_index)
    response_fields.last(response_fields.size - json_key_index - 1).each_with_index { |field, index| map[field] = ending_splits[index] }
    map
  end

  def self.handle_success(result)
    result
  end

  def client
    # adding the ssl options here for the request
    # verify certificate only in production
    verify = true #Rails.env.production? ? true : false
    # since we're using the default keystore, no need to import Yes Bank's certificates as they're signed
    ssl_options = {
        client_cert: OpenSSL::X509::Certificate.new(File.read(ENV['HOME'] + '/certificates/finly.crt')),
        client_key: OpenSSL::PKey::RSA.new(File.read(ENV['HOME'] + '/certificates/finly.key')),
        verify: verify,
        version: :SSLv23
    }
    # SSLv23 - will use the latest version of TLS that the destination supports. If that happens to be TLS 1.2, that will be used, otherwise the highest supported version:
    # https://stackoverflow.com/questions/11059059/is-it-possible-to-enable-tls-v1-2-in-ruby-if-so-how
    logger = Logger.new $stderr
    logger.level = Logger::DEBUG
    Faraday.new(:url => fetch(:url), ssl: ssl_options) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger, logger # log requests to STDOUT
      faraday.options[:timeout] = 60 # time out is 60 seconds
      faraday.use FaradayMiddleware::FollowRedirects, limit: 5
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  # Generate random request number
  # Format: R{time formatter}{random 5 digit number}
  def ref_number
    "R#{DateTime.now.strftime("%d%m%y%H%M%S")}#{rand(10000..99999)}"
  end

  def order_number
    "O#{DateTime.now.strftime("%d%m%y%H%M%S")}#{rand(10000..99999)}"
  end

  def agent_institution_id
    'YS01'
  end

  def channel_id
    'C1001'
  end

  def agent_id
    "18798"
  end

  def customer_param_for(param)
    return "NA" if params[param].blank?

    "#{params[param][:key]}=#{params[param][:value]}"
  end

  def self.format(obj)
    if obj.is_a?(Hash)
      formatted = {}
      obj.each do |k, v|
        formatted[k.underscore] = format(v)
      end
      return formatted
    elsif obj.is_a?(Array)
      formatted = []
      obj.each do |item|
        formatted << format(item)
      end
      return formatted
    else
      obj
    end
  end


end