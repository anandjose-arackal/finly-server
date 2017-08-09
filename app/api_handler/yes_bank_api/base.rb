class YesBankApi::Base < BaseHandler

  attr_accessor :client_id, :client_secret, :auth_username,
                :auth_password, :template, :config_path, :application_id,
                :customer_id

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