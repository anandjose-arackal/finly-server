class KotakBankApi::Base < BaseHandler
  attr_accessor :client_id, :client_secret, :auth_username,
                :auth_password, :template, :config_path, :application_id,
                :customer_id, :resource_not_found, :transfer_status_id,
                :configuration, :company_id, :account_number,
                :start_time, :end_time, :file_logger, :payment, :grant_type

  ILLEGAL_CHARACTERS = ['%', ',' "/", '\\', '(', ')', '@', '&', '.']

  def env_key
    'kotak_bank'
  end

  def base_url
    if params.present? and params[:base_url].present?
      (params[:base_url] or params['base_url'])
    elsif env_key.present?
      ENV["#{env_key}_base"] + "?apikey=#{self.configuration['API_KEY']}"
    else
      nil
    end
  end

  def path
    key = self.env_key
    if key.present?
      ENV["#{key}_path"]
    end
  end

  def init
    if Rails.env.production?
      values = Finly::SecureStorage::Connector.read('core/kotak_bank')
    else
      file_path = "#{Rails.root}/config/kotak_bank_config.yml"
      values = YAML.load_file(file_path)
    end


    # checking of there's a custom configuration for a particular company - stored in a variable called configuration
    company = self.company_id.present? ? Company.find_by_id(self.company_id) : nil
    if company&.feature_subscription&.current_account_connected and !["fc", :fc].include?(RequestStore.store[:current_app])
      if Rails.env.production?
        type = self.company_id.to_s # i.e. if the configuration associated with this particular company's id doesn't exist, use default
      else
        type = self.company_id.to_i
      end
    else
      type = 'default' # i.e. if the configuration associated with this particular company's id doesn't exist, use default
    end


    self.configuration = values[type] || {}
    self.client_id = self.configuration['client_id']
    self.client_secret = self.configuration['client_secret']
    self.grant_type = self.configuration['grant_type']
    # self.auth_username = self.configuration['username']
    # self.auth_password = self.configuration['password']
    # self.application_id = self.configuration['application_id']
    # self.customer_id = self.configuration['customer_id']
    self.account_number = self.configuration['ACCOUNT_NUMBER']
    # now calling the load_connection method to initialize the connection
    super()
  end

  def bank_action
  end

  def file_logger_base_params
    {}
  end

  def file_logger_params(logger_params)
    file_logger_base_params.merge(logger_params).merge(request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s))
  end

  def process
    # p = self.path
    if Rails.env.production?
      self.file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_kotak_bank_api.log', sync: true)
    end

    self.start_time = DateUtils.local_date_time

    begin
      # printing posting path and params unless it's production environment
      unless Rails.env.production?
        # puts "Posting Path: #{p}"
        puts "Post Params: #{self.template}"
      end

      self.response = self.connection.post do |req|
        # req.url p
        req.headers['Content-Type'] = "application/soap+xml;charset=UTF-8"
        req.headers['action'] = self.configuration['HEADERS'][bank_action]
        req.body = template
      end

      # Used for logging
      post_headers = {
          'Content-Type': "application/soap+xml;charset=UTF-8",
          'action': self.configuration['HEADERS'][bank_action]
      }

      self.end_time = DateUtils.local_date_time
      if Rails.env.production?
        post_params_hash = (Hash.from_xml(template) rescue nil)

        status_code = self.response.status rescue nil
        if status_code.present? && status_code == 200
          response_hash = (Hash.from_xml(self.response.body) rescue nil)
        else
          response_hash = self.response.body
        end

        file_logger.info(
            file_logger_params(
                {
                    path: base_url,
                    post_params: post_params_hash,
                    post_headers: post_headers,
                    response: response_hash,
                    status: status_code,
                    bank_action: bank_action,
                    request_time: (self.end_time - self.start_time),
                    success: true
                }
            )
        )
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      self.end_time = DateUtils.local_date_time

      # Used for logging
      post_headers = {
          'Content-Type': "application/soap+xml;charset=UTF-8",
          'action': self.configuration['HEADERS'][bank_action]
      }

      post_params_hash = (Hash.from_xml(template) rescue nil)
      if Rails.env.production?
        file_logger.warn(file_logger_params({
                                                path: base_url,
                                                post_params: post_params_hash,
                                                post_headers: post_headers,
                                                success: false,
                                                bank_action: bank_action,
                                                request_time: (self.end_time - self.start_time),
                                                failure_reason: 'Timeout'
                                            }))
      end

      self.timeout = true
      add_message :error, "Request timed out. Please try again"
      self.transfer_status_id = BankTransferStatus.id_for(:possible_failure)
      # create a failed bank transaction so that the record is preserved
      self.company = Company.find_by(id: self.transfer_request.company_id)

      self.bank_transaction = payment.reference_resources.first
      if self.bank_transaction&.is_a?(KotakBankTransaction)
        # just update the bank transaction with the latest details
        self.bank_transaction.update(
            bank_reference_number: self.transfer_request.bank_reference_number,
            transfer_status_id: self.transfer_status_id,
            bank_response: self.transfer_request.transaction_result
        )
        self.payment.update(retry_count: self.payment.retry_count.to_f + 1)
      else
        # this is an anomaly, so send email and flag it
        Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
      end
    rescue Faraday::ResourceNotFound
      self.end_time = DateUtils.local_date_time

      post_params_hash = (Hash.from_xml(template) rescue nil)

      # Used for logging
      post_headers = {
          'Content-Type': "application/soap+xml;charset=UTF-8",
          'action': self.configuration['HEADERS'][bank_action]
      }

      if Rails.env.production?
        file_logger.warn(file_logger_params({
                                                path: base_url,
                                                post_params: post_params_hash,
                                                success: false,
                                                post_headers: post_headers,
                                                bank_action: bank_action,
                                                request_time: (self.end_time - self.start_time),
                                                failure_reason: 'Resource Not Found'
                                            }))
      end

      self.resource_not_found = true
      add_message :error, "The service is temporarily down. Please try again later"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
      # rescue Exception => e
      #   stack_trace = e.message
      #   e.backtrace.each do |line|
      #     stack_trace += "\n#{line}"
      #   end
      #   if Rails.env.production?
      #     file_logger.warn(file_logger_params({path: p, post_params: post_params_hash, failure_reason: 'Crash', stack_trace: stack_trace, success: false}))
      #   end
    end

  end

  protected

  def load_connection(url = base_url)
    # verify certificate only in production
    verify = Rails.env.production? ? true : false

    ssl_options = {}

    logger = Logger.new $stderr
    logger.level = Logger::DEBUG
    self.connection = Faraday.new(:url => url, ssl: ssl_options) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      faraday.request :url_encoded # form-encode POST params
      unless Rails.env.production?
        faraday.response :logger, logger # log requests to STDOUT
      end
      faraday.options[:timeout] = 60 # time out is 60 seconds
      # faraday.use Faraday::Request::BasicAuthentication, auth_username, auth_password # use basic authentication
      # faraday.use FaradayMiddleware::FollowRedirects, limit: 5
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  def load_soap_template
    action = bank_action
    self.template = Liquid::Template.parse(File.read("#{Rails.root}/app/api_handler/kotak_bank_api/templates/#{action}.hbs"))
  end
end