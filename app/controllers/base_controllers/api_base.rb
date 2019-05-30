class BaseControllers::ApiBase < ApplicationController
  protect_from_forgery with: :null_session

  def authentication_scope
    :api
  end

  def decrypt_parameters
    path = Dir.home + '/certificates/encryption_certificates/finly_icici_final.key'
    private_key = OpenSSL::PKey::RSA.new(File.read(path))
    decrypted_response = private_key.private_decrypt(Base64.decode64(params))
    parsed_response = JSON.parse(decrypted_response)
    self.params = parsed_response
  end
end