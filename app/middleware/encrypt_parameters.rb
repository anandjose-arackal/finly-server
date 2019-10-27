# class EncryptParameters
#
#   def initialize(app)
#     @app = app
#   end
#
#   def decrypt_request_parameters(env)
#     encrypted_params = env['rack.input'].read
#     path = Dir.home + '/certificates/encryption_certificates/finly_icici_final.key'
#     private_key = OpenSSL::PKey::RSA.new(File.read(path))
#     decrypted_response = private_key.private_decrypt(Base64.decode64(encrypted_params))
#     env['rack.input'].string = decrypted_response
#   end
#
#   def call(env)
#     decrypt_request_parameters(env) rescue nil
#     env['rack.request.form_input'] = JSON.parse(env['rack.input'].string)
#     env['rack.request.form_hash'] = JSON.parse(env['rack.input'].string)
#
#     status, headers, response = @app.call(env)
#   end
#
# end