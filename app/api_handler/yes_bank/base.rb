class YesBank::Base < BaseOperation

  attr_accessor :client_id, :client_secret, :auth_username,
                :auth_password, :template, :config_path

  def env_key
    'yes_bank'
  end

  def init
    self.config_path = Rails.root.join('config', 'yes_bank_config.yml').to_s
    unless path.present?
      add_message :error, "Server error, try again later"
    end
    self.client_id = YAML.load_file(config_path)[Rails.env][:client_id]
    self.client_secret = YAML.load_file(config_path)[Rails.env][:client_secret]
    self.auth_username = YAML.load_file(config_path)[Rails.env][:username]
    self.auth_password = YAML.load_file(config_path)[Rails.env][:password]
  end

  def yes_bank_action

  end

  def validate
    unless client_id.present? && client_secret.present? && auth_username.present? && auth_password.present?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def process

  end

  protected

  def load_connection(url = base_url)
    # adding the ssl options here for the request
    # verify certificate only in production
    verify = Rails.env.production? ? true : false
    ssl_options = {
        client_cert: OpenSSL::X509::Certificate.new(File.read(ENV['HOME'] + 'certificates/finly.crt')),
        client_key: OpenSSL::PKey::RSA.new(File.read(ENV['HOME'] + 'certificates/finly.key')),
        ca_path: ENV['HOME'] + 'certificates/ybl.pem',
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
    self.template = Liquid::Template.parse(File.read("./../templates/#{action}.hbs"))
  end
end