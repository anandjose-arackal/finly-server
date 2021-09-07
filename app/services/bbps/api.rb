class Bbps::Api < ServiceApi
  include Transactions::BackgroundWorker
  sidekiq_options queue: :yes_bank_bbps
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
  class_attr :encryption_key, default: "2321bd46f297a35241efe1744df7898c"
  skip_user_authorization!
  http_method :post
  mime_type "application/json"
  url 'http://180.179.170.6:1012/portal/service/npciservice'#Rails.application.config_for(:bbps_config)&.with_indifferent_access&.dig('base_url')
  header 'X-IBM-Client-Id', Rails.application.config_for(:bbps_config)&.with_indifferent_access&.dig('client_id')
  header 'X-IBM-Client-Secret', Rails.application.config_for(:bbps_config)&.with_indifferent_access&.dig('client_secret')
  header "AUTH","7ljbVcKc1Ka5tpaGAyAvR/vNDcTzk1C+BRhUdM9zB3s="
  body -> (user, params) { body }
  client -> (user, params) { client }
  parse -> (user, params, response) { parse_response(user, params, response) }

  matcher :build_matcher

  def self.build_matcher(options, result)
    Dry::Matcher.new(
        success: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Success", result; result['response.parsed']&.dig('status') == 'Y'},
            resolve: -> (result) { handle_success(result) }
        ),
        error: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Error", result; result['response.parsed']&.dig('status') == 'N'},
            resolve: -> (result) { handle_error(result['response.parsed']) }
        ),
        failure: Dry::Matcher::Case.new(
            match: -> (result) {p "Matcher:Failure", result; true},
            resolve: -> (result) {result}
        )
    )
  end

  def body
    m1 = "{\"chId\":1,\"custDetails\":{\"mobileNo\":\"8879397255\",\"customerTags\":[{\"name\":\"EMAIL\",\"value\":\"mk.chekuri@gmail.com\"},{\"name\":\"AADHAAR\",\"value\":\"499118665246\"},{\"name\":\"PAN\",\"value\":\"BXXCG7754K\"}]},\"agentDetails\":{\"agentId\":\"YB31YB41MOB521611569\",\"deviceTags\":[{\"name\":\"IP\",\"value\":\"124.170.23.24\"},{\"name\":\"MAC\",\"value\":\"01-23-45-67-89-ab\"}]},\"billDetails\":{\"billerId\":\"ASCE00000NATGK\",\"customerParams\":[{\"name\":\"Loan number\",\"value\":\"17000036\"}]}}"
    m2 = "sample"
    message = generate_message
    #fetch : message = "FCEtV3bbmRQqRPDe++Exq4c5eAcgD+xEE8313baqaxOzfvoqw/gQsG4LbOMABfRySPe3WTynow1NRJ6gNjnhWi9ujU4X4Jxl1YiMCB1fGXa1snS1acHr5h3981JB6KvahHOeGfp7zVd5w96Sc+bWwOi24fWGV+n8lGvMa+SDQPNqmhhDJbmAfPAdzxm/TPy9UNw5IWaOL7hXAxdKzQNO1qZIldpoXbdLn5GAvBJY9PdGkiXwVxtNwp9UIPemKQAfnvLYx5tV80WkZlp+c/EqWVrlaxQ1Dm7Gg7rXNdJiTx10tVRpjQ+LUEgdwWRd/ZeS7I3eVU0PavZ7kD5iY1rl+ouoriV5mWRcGceTwUeGRWMb1R6MqEd8xNeI/06B89ioRCfMjtRuoQpcvvql0RL3bvYxUdwSBz7OPcLxV1UAuj451kvEe9kmyRu3P6Vm0kDDYxvfGxo27ecH8xp0Rq7CyuVB37kL2X4CqW6eub7MUVknXbtuknj8wLzQvqrUFvATBWoX7rqus5WFH48pxntwy2aP0GZ+fpmHbBUFc1uTJXZo3aqbPt2B7Tgk0ZC1mLQx38pdfyijERo6emqD2/LS5A=="
    #status
    message = "Mspt9PGdqqUm1MVwjlLBgeU9Fj37gtaTTPYGim1yvm9vAFG98+Lb8Ij8+Kp7Eg3B0HKYWlpmU2lK2YuHxxjeAKXGa0SXI6Fqw7BhCpfwf1gq7Ls7uHuNG/rHM7bgIWJ3" 
    Rails.logger.info("Encryption key :: #{self.class.encryption_key}")
    encrypted_message = encrypt(m1)
    byebug
    Rails.logger.info("Encrypted message :: #{encrypted_message}")
    body = {request: message, agentInstitutionId: agent_institution_id}
    log_generator.merge({request_raw_message: message})
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
  # def self.encryption_key
  #   ''
  # end

  def encrypt(message)
    result = nil
    Open3.popen3("java UPISecurity.java \"#{message}\" \"#{self.class.encryption_key}\"") do |stdin, stdout, strerr|
       result = stdout.read
       result = strerr.read
    end
    result
  end

  # Map the response splits with the respective headers provided by response_fields
  def parse_response(user, params, response)
    byebug
    Rails.logger.info "BBPS response :: #{response}"
       Rails.logger.info "BBPS response :: #{response.inspect}"
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    # Request failed
    return Failure("Error connecting with BBPS") if splits[1].blank?

    map = {}.with_indifferent_access
    fetch(:response_fields).each_with_index { |field, index| map[field] = splits[index] }
    map
  end

  # The JSON response has a pipe delimiter in the biller_details. Hence, handling it correctly
  def parse_json_response(json_key, user, params, response)
    Rails.logger.info "BBPS json response :: #{response}"

        Rails.logger.info "BBPS json response :: #{response.inspect}"
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    # Request failed
    return Failure("Error connecting with BBPS") if splits[1].blank?

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

  def self.handle_error(data)
    data
  end

  def client
    # adding the ssl options here for the request
    # verify certificate only in production
    verify = true #Rails.env.production? ? true : false
    # since we're using the default keystore, no need to import Yes Bank's certificates as they're signed
    ssl_options = {
        client_cert: "",#OpenSSL::X509::Certificate.new(File.read(ENV['HOME'] + '/certificates/finly.crt')),
        client_key: "",#OpenSSL::PKey::RSA.new(File.read(ENV['HOME'] + '/certificates/finly.key')),
        verify: verify,
        version: :SSLv23
    }
    # SSLv23 - will use the latest version of TLS that the destination supports. If that happens to be TLS 1.2, that will be used, otherwise the highest supported version:
    # https://stackoverflow.com/questions/11059059/is-it-possible-to-enable-tls-v1-2-in-ruby-if-so-how
    logger = Logger.new $stderr
    logger.level = Logger::DEBUG
    Faraday.new(:url => "http://180.179.170.6:1012/portal/service/npciservice/fetch", ssl: ssl_options) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger, logger # log requests to STDOUT
      faraday.options[:timeout] = 180 # time out is 180 seconds
      faraday.options[:open_timeout] = 180 # time out is 180 seconds
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
    Rails.application.config_for(:bbps_config)&.with_indifferent_access&.dig('agent_institution_id')
  end

  def channel_id
    Rails.application.config_for(:bbps_config)&.with_indifferent_access&.dig('channel_id')
  end

  def agent_id
    Rails.application.config_for(:bbps_config)&.with_indifferent_access&.dig('agent_id')
  end

  def customer_param_for(param)
    return "NA" if params[param].blank?

    "#{params[param][:key]}=#{params[param][:value]}"
  end

  def amount_for(param)
    return "NA" if params[param].blank?
    params[param].to_f * 100
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