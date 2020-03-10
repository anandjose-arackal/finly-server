
class YesBankApi::Base < BaseHandler

  attr_accessor :client_id, :client_secret, :auth_username,
                :auth_password, :template, :config_path, :application_id,
                :customer_id, :resource_not_found, :transfer_status_id,
                :configuration, :company_id, :account_number,
                :start_time, :end_time, :file_logger, :payment

  ILLEGAL_CHARACTERS = ['%', ',' "/", '\\', '(', ')', '@', '&', '.']

  def env_key
    'yes_bank'
  end

  def init
    # self.config_path = Rails.root.join('config', 'yes_bank_config.yml').to_s
    # self.config_path = "#{Dir.home}/app/shared/config/yes_bank_config.yml"
    # unless config_path.present?
    #   add_message :error, "Server error, try again later"
    # end


    if Rails.env.production?
      values = Finly::SecureStorage::Connector.read('core/yes_bank')
    else
      path = "#{Rails.root}/config/yes_bank_config.yml"
      values = YAML.load_file(path)
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
    self.auth_username = self.configuration['username']
    self.auth_password = self.configuration['password']
    self.application_id = self.configuration['application_id']
    self.customer_id = self.configuration['customer_id']
    self.account_number = self.configuration['account_number']
    # now calling the load_connection method to initialize the connection
    super()
  end

  def yes_bank_action

  end

  def validate
    unless client_id.present? && client_secret.present? && auth_username.present? && auth_password.present?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def file_logger_base_params
    {}
  end

  def file_logger_params(logger_params)
    file_logger_base_params.merge(logger_params).merge(request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s))
  end

  # because this is common for all Yes Bank API calls
  def process
    p = self.path
    if Rails.env.production?
      self.file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_yes_bank_api.log', sync: true)
    end

    self.start_time = DateUtils.local_date_time

    begin

      # printing posting path and params unless it's production environment
      unless Rails.env.production?
        puts "Posting Path: #{p}"
        puts "Post Params: #{self.template}"
        ap "Posting Path: #{p}"
        ap "Post Params: #{self.template}"
      end


      self.response = self.connection.post do |req|
        req.url p
        req.headers['Content-Type'] = 'application/xml'
        req.headers['X-IBM-Client-Id'] = client_id
        req.headers['X-IBM-Client-Secret'] = client_secret
        req.body = template
      end

      ap response&.body

      self.end_time = DateUtils.local_date_time

      if Rails.env.production?
        post_params_hash = (Hash.from_xml(template) rescue nil)
        response_hash = (Hash.from_xml(self.response.body) rescue nil)
        status_code = self.response.status rescue nil
        file_logger.info(
            file_logger_params(
                {
                    path: p,
                    post_params: post_params_hash,
                    response: response_hash,
                    status: status_code,
                    yes_bank_action: yes_bank_action,
                    request_time: (self.end_time - self.start_time),
                    success: true
                }
            )
        )
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      self.end_time = DateUtils.local_date_time

      post_params_hash = (Hash.from_xml(template) rescue nil)
      if Rails.env.production?
        file_logger.info(file_logger_params({path: p, post_params: post_params_hash, success: false, yes_bank_action: yes_bank_action, request_time: (self.end_time - self.start_time), failure_reason: 'Timeout'}))
      end

      self.timeout = true
      add_message :error, "Request timed out. Please try again"
      self.transfer_status_id = BankTransferStatus.id_for(:possible_failure)
      # create a failed bank transaction so that the record is preserved
      self.company = Company.find_by(id: self.transfer_request.company_id)
      self.bank_transaction = payment.reference_resources.first
      if self.bank_transaction.is_a?(YesBankTransaction)
        # just update the bank transaction with the latest details
        self.bank_transaction.update(
            bank_reference_number: self.transfer_request.bank_reference_number,
            transfer_status_id: self.transfer_status_id,
            bank_response: self.transfer_request.transaction_result
        )
        self.payment.update(retry_count: self.payment.retry_count.to_f + 1)
      else
        # this is an anomaly, so send email and flag it
        if self.payment.present? && self.bank_transaction.blank?
          Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
        end
      end
    rescue Faraday::ResourceNotFound
      self.end_time = DateUtils.local_date_time

      post_params_hash = (Hash.from_xml(template) rescue nil)

      if Rails.env.production?
        file_logger.info(file_logger_params({path: p, post_params: post_params_hash, success: false, yes_bank_action: yes_bank_action, request_time: (self.end_time - self.start_time), failure_reason: 'Resource Not Found'}))
      end

      self.resource_not_found = true
      add_message :error, "The service is temporarily down. Please try again later"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
    # rescue Faraday::SSLError
    #   debugger
    #   # temporarily making this so that the bank transaction gives off a success
    #   self.transfer_status_id = 1
    #   self.bank_transaction = payment.reference_resources.first
    #   self.bank_transaction.update(
    #       bank_reference_number: "afbioheakdfbkasdfjbg",
    #       transfer_status_id: self.transfer_status_id,
    #       bank_response: "",
    #       beneficiary_full_name: "some shit"
    #   )
    end

  end


  protected

  def load_connection(url = base_url)
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
    self.connection = Faraday.new(:url => url, ssl: ssl_options) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger, logger # log requests to STDOUT
      faraday.options[:timeout] = 60 # time out is 60 seconds
      faraday.use Faraday::Request::BasicAuthentication, auth_username, auth_password # use basic authentication
      faraday.use FaradayMiddleware::FollowRedirects, limit: 5
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end
  end

  def load_soap_template
    action = yes_bank_action
    self.template = Liquid::Template.parse(File.read("#{Rails.root}/app/api_handler/yes_bank_api/templates/#{action}.hbs"))
  end
end