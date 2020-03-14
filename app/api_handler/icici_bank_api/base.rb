class IciciBankApi::Base < BaseHandler

  attr_accessor :company_details, :company, :parsed_response, :decrypted_response, :file_logger,
                :start_time, :end_time, :transfer_status_id, :payment, :bank_transaction

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

  def file_logger_base_params
    {}
  end

  def file_logger_params(logger_params)
    file_logger_base_params.merge(logger_params).merge(request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s))
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
    begin
      self.decrypted_response = private_key.private_decrypt(Base64.decode64(body))
    rescue OpenSSL::PKey::RSAError
      self.decrypted_response = body
    end
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

      if Rails.env.production?
        post_params_hash = raw_api_params
        response_hash = self.parsed_response
        status_code = self.response.status rescue nil
        file_logger.info(
            file_logger_params(
                {
                    path: p,
                    post_params: post_params_hash,
                    response: response_hash,
                    status: status_code,
                    company: self.company&.name,
                    icici_bank_action: env_key,
                    request_time: (self.end_time - self.start_time),
                    success: true
                }
            )
        )
      end

    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      # handle this case by updating the bank transaction to possible failure and then checking the
      # status of the transaction later using the TransactionCheck API call
      self.end_time = DateUtils.local_date_time

      self.parsed_response = decrypt_response(self.response.body) rescue ""

      if Rails.env.production?
        post_params_hash = raw_api_params
        response_hash = self.parsed_response
        status_code = self.response.status rescue nil
        file_logger.info(
            file_logger_params(
                {
                    path: p,
                    post_params: post_params_hash,
                    response: response_hash,
                    status: status_code,
                    company: self.company&.name,
                    icici_bank_action: env_key,
                    request_time: (self.end_time - self.start_time),
                    success: false,
                    failure_reason: "Timeout"
                }
            )
        )
      end

      # in this case we have to mark the payment and bank transaction as possible failure
      add_message :error, "Request timed out. Please try again"
      self.transfer_status_id = BankTransferStatus.id_for(:possible_failure)
      # create a failed bank transaction so that the record is preserved
      self.company = Company.find_by(id: self.transfer_request.company_id)

      self.bank_transaction = payment.reference_resources.first
      if self.bank_transaction.is_a?(IciciBankTransaction)
        self.bank_transaction.update(transfer_status_id: self.transfer_status_id)
      else
        if self.payment.present? && self.bank_transaction.blank?
          Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
        end
      end

      # if self.payment&.reference_resource&.is_a?(IciciBankTransaction)
      #   # just update the bank transaction with the latest details
      #   self.bank_transaction = payment.reference_resource
      #   self.bank_transaction.update(
      #       transfer_status_id: self.transfer_status_id
      #   )
      # else
      #   # if payment object exists but it didn't have an associated bank transaction object
      #   if self.payment.present? && self.payment.reference_resource.blank?
      #     Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
      #   end
      # end

    rescue Faraday::ResourceNotFound
      self.end_time = DateUtils.local_date_time

      post_params_hash = raw_api_params
      response_hash = self.parsed_response
      status_code = self.response.status rescue nil
      file_logger.info(
          file_logger_params(
              {
                  path: p,
                  post_params: post_params_hash,
                  response: response_hash,
                  status: status_code,
                  company: self.company&.name,
                  icici_bank_action: env_key,
                  request_time: (self.end_time - self.start_time),
                  success: false,
                  failure_reason: "Resource Not Found"
              }
          )
      )

      add_message :error, "The service is temporarily down. Please try again later"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)

      self.bank_transaction = payment.reference_resources.first
      if self.bank_transaction.is_a?(IciciBankTransaction)
        self.bank_transaction.update(transfer_status_id: self.transfer_status_id)
      else
        if self.payment.present? && self.bank_transaction.blank?
          Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
        end
      end
      # if self.payment&.reference_resource&.is_a?(IciciBankTransaction)
      #   # just update the bank transaction with the latest details
      #   self.bank_transaction = payment.reference_resource
      #   self.bank_transaction.update(
      #       transfer_status_id: self.transfer_status_id
      #   )
      # else
      #   # this is an anomaly, so send email and flag it
      #   if self.payment.present? && self.payment.reference_resource.blank?
      #     Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
      #   end
      # end
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