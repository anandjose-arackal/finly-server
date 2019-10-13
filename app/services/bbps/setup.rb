module Bbps::Setup

  def self.included(base)
    base.class_attr :request_fields, default: []
    base.class_attr :response_fields, default: []
    base.class_attr :success_object
    base.http_method :post
    base.url "https://uat.yesbank.in"
    base.body -> (user, params) { body }
    base.client -> (user, params) { client }
    base.parse -> (user, params, response) {parse_response(response)}
    base.matcher :success,
                 match: -> (result) {result['response.parsed']&.dig(:status) == 'Y'},
                 resolve: -> (result) {on_success(result)}
    base.matcher :failure,
                 match: -> (result) {true},
                 resolve: -> (result) {result['response.parsed']}
  end

  def body
    message = generate_message
    {requestMsg: encrypt(message), AgentInstitutionId: agent_institution_id}
  end

  def generate_message
    req = []
    fetch(:request_fields).each do |field|
      req << self.send(field)
    end
    req.join("|")
  end

  def additional_field
    "NA"
  end

  def last_updated_timestamp
    'NA'
  end

  def encryption_key
    '4d5390bef3ef1ee3d4a7e77fd42238cb'
  end

  def encrypt(message)
    AES.encrypt(message, encryption_key)
  end

  def decrypt(message)
    AES.decrypt(message, encryption_key)
  end

  # Map the response splits with the respective headers provided by response_fields
  def parse_response(user, params, response)
    return Failure("Invalid response") unless response.status == 200
    json = JSON.parse response.body
    return Failure("Invalid response") unless json&.dig('responseMsg').present?

    splits = json["responseMsg"].split("|")
    map = {}.with_indifferent_access
    response_fields.each_with_index { |field, index| map[field] = splits[index] }
    map
  end

  def on_success(result)
    nil
  end

  def client
    # adding the ssl options here for the request
    # verify certificate only in production
    verify = Rails.env.production? ? true : false
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
      faraday.use Faraday::Request::BasicAuthentication, auth_username, auth_password # use basic authentication
      faraday.use FaradayMiddleware::FollowRedirects, limit: 5
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  def auth_username
    'vivek.a@finly.io'  end

  def auth_password
    'nQ0ydemPsL@A2pY2Ta#*'
  end

  def message_code
    "B7000"
  end

  def ref_number
    "BILLERLISTREFAGENT170322120601"
  end

  def agent_institution_id
    "YS01"
  end

  def channel_id
    "C1001"
  end

end