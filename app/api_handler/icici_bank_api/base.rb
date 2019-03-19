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
    public_key = OpenSSL::PKey::RSA.new(File.read(ENV['HOME'] + '/certificates/cibnextapiuat.pem'))
    encrypted_params = Base64.encode64(public_key.public_encrypt(json_params))
  end



end