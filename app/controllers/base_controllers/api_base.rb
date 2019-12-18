class BaseControllers::ApiBase < ApplicationController
  protect_from_forgery with: :null_session

  def authentication_scope
    :api
  end

  # def decrypt_parameters
  #   if current_user.company.request_encryption_enabled?
  #     path = Dir.home + '/certificates/encryption_certificates/finly_icici_final.key'
  #     private_key = OpenSSL::PKey::RSA.new(File.read(path))
  #     encrypted_params = params[:payment_parameters]
  #     decrypted_params = private_key.private_decrypt(Base64.decode64(encrypted_params)) rescue ""
  #     parsed_decrypted_params = JSON.parse(decrypted_params)
  #     self.params = parsed_decrypted_params
  #   end
  # end
end