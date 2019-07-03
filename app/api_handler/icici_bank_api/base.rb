class IciciBankApi::Base < BaseHandler

  attr_accessor :company_details, :company, :parsed_response, :decrypted_response, :file_logger,
                :start_time, :end_time

  def init
    self.company = user&.company if self.company.blank?
    if Rails.env.production?
      values = Finly::SecureStorage::Connector.read('core/icici_bank')
      type = self.company.id.to_s
    else
      path = "#{Rails.root}/config/icici_bank_config.yml"
      values = YAML.load_file(path)
      type = self.company.id
    end
    self.company_details = values[type]

    super()
  end

  def encrypt_params(params = {})
    json_params = params.to_json
    if Rails.env.production?
      path = Dir.home + '/certificates/icici_certificates_final/cibnextapiprod.pem'
    else
      path = Dir.home + '/certificates/icici_certificates_final/cibnextapiuat.pem'
    end
    cert = OpenSSL::X509::Certificate.new(File.read(path))
    public_key = cert.public_key
    encrypted_params = Base64.encode64(public_key.public_encrypt(json_params))
  end

  def decrypt_response(body)
    # enter logic to parse the encrypted response
    # first decrypt the response
    if Rails.env.production?
      path = Dir.home + '/certificates/icici_certificates_final/finly_icici_production.key'
    else
      path = Dir.home + '/certificates/icici_certificates_final/finly_icici_final.key'
    end
    private_key = OpenSSL::PKey::RSA.new(File.read(path))
    self.decrypted_response = private_key.private_decrypt(Base64.decode64(body))
    parsed_response = JSON.parse(decrypted_response) rescue {}
    return parsed_response
  end

  def process
    p = self.path
    raw_params = raw_api_params
    request_params = post_params

    self.start_time = DateUtils.local_date_time

    if Rails.env.production?
      self.file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_icici_bank_api.log', sync: true)
    end
    # start of the path for posting data to ICICI's servers
    begin

      puts "Posting path: #{base_url} #{p}"
      puts "Post Params: #{raw_params}"

      self.response = self.connection.post do |req|
        req.url p
        req.headers['accept'] = "*/*"
        req.headers['content-type'] = "text/plain"
        req.headers['apikey'] = self.company_details["API_KEY"]
        if Rails.env.production?
          req.headers['x-forwarded-for'] = "13.232.176.84" # production background server address
        else
          req.headers['x-forwarded-for'] = "35.154.97.60" # todo - temporary, will be changed in production
        end

        req.body = request_params
      end

      self.end_time = DateUtils.local_date_time

      puts "Encrypted Response: "
      ap self.response.body

      puts "Decrypted Response: "
      ap decrypt_response(self.response.body)

      # now parse the response and store it in the parsed_response
      self.parsed_response = decrypt_response(self.response.body)

      # if Rails.env.production?
      #   post_params_hash = raw_api_params
      #   response_hash = self.parsed_response
      #   status_code = self.response.status rescue nil
      #   file_logger.info(
      #       file_logger_params(
      #           {
      #               path: p,
      #               post_params: post_params_hash,
      #               response: response_hash,
      #               status: status_code,
      #               icici_bank_action: env_key,
      #               request_time: (self.end_time - self.start_time),
      #               success: true
      #           }
      #       )
      #   )
      # end

    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      # handle this case by updating the bank transaction to possible failure and then checking the
      # status of the transaction later using the TransactionCheck API call

    rescue Faraday::ResourceNotFound


    end
  end

  protected

  def load_connection(url = base_url)
    # adding the ssl options here for the request
    # verify certificate only in production
    # todo - need to check if we need to use SSL options in the request as well
    # since we're using the default keystore, no need to import ICICI Bank's certificates as they're signed

    logger = Logger.new $stderr
    logger.level = Logger::DEBUG
    self.connection = Faraday.new(:url => url) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      faraday.request :url_encoded # form-encode POST params
      unless Rails.env.production?
        faraday.response :logger, logger # log requests to STDOUT
      end
      faraday.options[:timeout] = 60 # time out is 60 seconds
      faraday.use FaradayMiddleware::FollowRedirects, limit: 5
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end


end