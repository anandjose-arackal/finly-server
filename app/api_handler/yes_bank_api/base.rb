class YesBankApi::Base < BaseHandler

  attr_accessor :client_id, :client_secret, :auth_username,
                :auth_password, :template, :config_path, :application_id,
                :customer_id, :resource_not_found, :transfer_status_id

  ILLEGAL_CHARACTERS = ['%', ',' "/", '\\', '(', ')', '@', '&']

  def env_key
    'yes_bank'
  end

  def init
    self.config_path = Rails.root.join('config', 'yes_bank_config.yml').to_s
    unless config_path.present?
      add_message :error, "Server error, try again later"
    end
    self.client_id = YAML.load_file(config_path)[Rails.env]['client_id']
    self.client_secret = YAML.load_file(config_path)[Rails.env]['client_secret']
    self.auth_username = YAML.load_file(config_path)[Rails.env]['username']
    self.auth_password = YAML.load_file(config_path)[Rails.env]['password']
    self.application_id = YAML.load_file(config_path)[Rails.env]['application_id']
    self.customer_id = YAML.load_file(config_path)[Rails.env]['customer_id']
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

  # because this is common for all Yes Bank API calls
  def process
    p = self.path
    begin
      puts "Posting Path: #{p}"
      puts "Post Params: #{self.template}"

      self.response = self.connection.post do |req|
        req.url p
        req.headers['Content-Type'] = 'application/xml'
        req.headers['X-IBM-Client-Id'] = client_id
        req.headers['X-IBM-Client-Secret'] = client_secret
        req.body = template
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      self.timeout = true
      add_message :error, "Request timed out. Please try again"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
    # todo - temporary - rescue SSL error to simulate various cases
    # rescue Faraday::SSLError
    #   # simulating different cases
    #   puts "WE GOT HERE EVERYBODY! LOOKS LIKE THIS IS GONNA BE A GOOD RIDE!"
    #   # self.response.status_code = 500
    #   self.parsed_response = {
    #       "Envelope" => {
    #           "xmlns:soapenv" => "http://www.w3.org/2003/05/soap-envelope",
    #           "Body" => {
    #               "Fault" => {
    #                   "xmlns:billdesk" => "http://www.quantiguous.com/dfdl/billdesk",
    #                   "xmlns:flex" => "http://www.oracle.com/flexcube",
    #                   "xmlns:npci" => "http://www.npci.org.in",
    #                   "xmlns:vp" => "http://www.ibm.com/dfdl/ISO8583-1993",
    #                   "xmlns:ycs" => "https://uat.yalamanchili.in/",
    #                   "xmlns:pt" => "https://www.puratech.co.in/",
    #                   "xmlns:http" => "http://www.quantiguous.com/services",
    #                   "xmlns:ns" => "http://www.quantiguous.com/services",
    #                   "xmlns:atom" => "http://www.atomtech.in/imps",
    #                   "xmlns:iib" => "http://www.ibm.com/iib",
    #                   "xmlns:soapenv12" => "http://www.w3.org/2003/05/soap-envelope",
    #                   "Code" => {
    #                       "Value" => "soapenv12:Sender",
    #                       "Subcode" => {
    #                           "Value" => "ns:E504",
    #                           "Subcode" => {
    #                               "Value" => "ns:E504"
    #                           }
    #                       }
    #                   },
    #                   "Reason" => {
    #                       "Text" => "Bad Gateway"
    #                   },
    #                   "Detail" => {
    #                       "ExceptionList" => {
    #                           "RecoverableException" => {
    #                               "File" => "/build/slot1/S900_P/src/DataFlowEngine/PluginInterface/ImbJniNode.cpp",
    #                               "Line" => "1304",
    #                               "Function" => "ImbJniNode::evaluate",
    #                               "Type" => "ComIbmRouteNode",
    #                               "Name" => "gen/fundsTransferByCustomerService2#FCMComposite_1_8.gen/transfer_Request_Response#FCMComposite_1_28.atom/invoke5#FCMComposite_1_1.atom/invoke2#FCMComposite_1_1.atom/invoke#FCMComposite_1_1",
    #                               "Label" => "gen.fundsTransferByCustomerService2.atom/invoke.is.ForeignRemittance?",
    #                               "Catalog" => "BIPmsgs",
    #                               "Severity" => "3",
    #                               "Number" => "2230",
    #                               "Text" => "Caught exception and rethrowing",
    #                               "Insert" => {
    #                                   "Type" => "14",
    #                                   "Text" => "gen.fundsTransferByCustomerService2.atom/invoke.is.ForeignRemittance?"
    #                               },
    #                           }
    #                       }
    #                   }
    #               }
    #           }
    #       }
    #   }
    rescue Faraday::ResourceNotFound
      self.resource_not_found = true
      add_message :error, "The service is temporarily down. Please try again later"
      self.transfer_status_id = BankTransferStatus.id_for(:failed)
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
        verify: verify
    }
    self.connection = Faraday.new(:url => url, ssl: ssl_options) do |faraday|
      # builder.use Faraday::Request::UrlEncoded
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger # log requests to STDOUT
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