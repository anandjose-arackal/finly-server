class IciciBankApi::Base < BaseHandler

  attr_accessor :company_details, :company

  def init
    self.company = params[:company]
    if Rails.env.production?
      values = Finly::SecureStorage::Connector.read('core/icici_bank')
      type = self.company.id.to_s
    else
      path = "#{Rails.root}/config/icici_bank_config.yml"
      values = YAML.load_file(path)
      type = self.company.id
    end
    self.company_details = values[type]
  end

  def encrypt_params(params = {})
    json_params = params.to_json
    # todo - check if this is the right file to use for encryption
    public_key = OpenSSL::PKey::RSA.new(File.read(ENV['HOME'] + '/certificates/cibnextapiuat.pem'))
    encrypted_params = Base64.encode64(public_key.public_encrypt(json_params))
  end

  def process
    p = self.path
    raw_params = raw_api_params
    # start of the path for posting data to ICICI's servers
    begin

      puts "Posting path: #{p}"
      puts "Post Params: #{raw_params}"



    end
  end

  protected

  def load_connection
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