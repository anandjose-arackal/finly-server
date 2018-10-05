class Sso::TokenController < Oauth::TokenController

  attr_accessor :token

  def create
    unless pre_process
      return
    end

    # extracting the email from the params
    data = params[:data]
    if data.blank?
      return
    end
    self.token = params[:token]
    if self.token.blank?
      return
    end

    email, timestamp, request_encrypted_hash = extract_email_from_encrypted_data(data)
    if email.blank? || timestamp.blank?
      return
    end
    params[:username] = email # for the doorkeeper method that authenticates based on the key 'username'
    params[:sso_skip_password] = true # because this is used by doorkeeper to skip the password validation
    # now implementing the SHA512 for the email and timestamp with the given key to check if
    # this particular user can be authenticated and logged into Finly
    finly_encrypted_hash = sha512_encrypted_email(email, timestamp)
    if finly_encrypted_hash == request_encrypted_hash
      # if true
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
    else
      # todo ?
    end
  end

  protected

  def on_create_success(response)
    params[:request] = request
    params[:application] = 'web'
    # self.response.set_cookie 'access_token', {:value => response.token.token, :httponly => true}
    # self.response.set_cookie 'refresh_token', {:value => response.token.refresh_token, :httponly => true}
    cookies["access_token"] = {:value => @token.token, :httponly => true, :expires => 15.days.from_now}
    cookies["refresh_token"] = {:value => @token.refresh_token, :httponly => true, :expires => 15.days.from_now}

    # render json: {}, status: 200
    render_json 'remunance/token/create.json.jbuilder', response.status
  end

  def auth_scope
    :web
  end

  def sso_keys
    sso_key = SsoKey.find_by(token: self.token)
    if sso_key.blank?
      return {}
    else
      return sso_key
    end
  end

  def extract_email_from_encrypted_data(data)
    base64_decrypted = Base64.decode64(data)
    xor_decoded = XorEncryptorDecryptor.encrypt_decrypt(base64_decrypted, sso_keys[:xor_key])
    base64_decoded_again = Base64.decode64(xor_decoded)
    parsed_payload = JSON.parse(base64_decoded_again)
    email = parsed_payload["email"]
    timestamp = parsed_payload["timestamp"]
    request_encrypted_hash = parsed_payload["hash"]
    [email, timestamp, request_encrypted_hash]
  end

  def sha512_encrypted_email(email, timestamp)
    key = sso_keys[:sha512_key] # extracting the encryption key for this particular company
    concatenated_string = email.to_s + key.to_s + timestamp.to_s
    encrypted_string = Digest::SHA512.hexdigest(concatenated_string)
  end

  def verify_company_status(user)
    super
    company = user&.company rescue nil
    if company.present? && !company.configuration.sso_enabled
      return false
    end
    true
  end

end