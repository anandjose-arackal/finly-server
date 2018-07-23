class DarwinboxSso::TokenController < Oauth::TokenController

  def create
    @user = User.find 18 # temporary override for this user
    render_json 'oauth/token/create_sso.json.jbuilder', response.status

    # extracting the email from the params
    data = params[:data]
    if data.blank?
      return
    end
    email, timestamp, request_encrypted_hash = extract_email_from_encrypted_data(data)
    if email.blank? || timestamp.blank?
      return
    end
    params[:username] = email # for the doorkeeper method that authenticates based on the key 'username'
    # now implementing the SHA512 for the email and timestamp with the given key to check if
    # this particular user can be authenticated and logged into Finly
    finly_encrypted_hash = sha512_encrypted_email(email, timestamp)
    if finly_encrypted_hash == request_encrypted_hash
      # i.e. this is a successful login attempt, generate token and return the
      # access token and the refresh token for this particular user's login
      response = authorize_response
      headers.merge! response.headers
      self.status = response.status

      if self.status == 200
        @auth_grant = response
        @token = response.token
        @user = current_user(response&.token)
        if verify_company_status(@user)
          User::Track::Login.(@user, params)
          on_create_success(response)
        end
      else
        self.response_body = response.body.to_json
      end
    end
  end

  protected

  def on_create_success(response)
    render_json 'oauth/token/create_sso.json.jbuilder', response.status
  end

  def auth_scope
    :darwinbox
  end

  def extract_email_from_encrypted_data(data)
    base64_decrypted = Base64.decode64(data)
    xor_decoded = XorEncryptorDecryptor.encrypt_decrypt(base64_decrypted, Constants::XOR_KEY)
    base64_decoded_again = Base64.decode64(xor_decoded)
    parsed_payload = JSON.parse(base64_decoded_again)
    email = parsed_payload["email"]
    timestamp = parsed_payload["timestamp"]
    request_encrypted_hash = parsed_payload["hash"]
    [email, timestamp, request_encrypted_hash]
  end

  def sha512_encrypted_email(email, timestamp)
    key = Constants::SHA512_KEY # extracting the encryption key for this particular company
    concatenated_string = email.to_s + key.to_s + timestamp.to_s
    encrypted_string = Digest::SHA512.hexdigest(concatenated_string)
  end

  def verify_company_status(user)
    super
    company = user&.company rescue nil
    if company.present? && !company.configuration.darwinbox_sso_enabled
      return false
    end
    true
  end
end