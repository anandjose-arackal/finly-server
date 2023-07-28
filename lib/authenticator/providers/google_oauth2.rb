require 'net/http'
# this class will handle the authentication that needs to be done for users who are logging in using SSO
# For now this only supports SAML based authentication, but it can support others in the future
class Authenticator::Providers::GoogleOauth2 < Authenticator::Providers::Base

  attr_accessor :username, :user_info

  def self.accept?(request)
    scopes = request.params[:scope]
    scopes = [scopes] unless scopes.respond_to?(:each)
    scopes&.size == 1 and ["web", "mobile", "chrome", "api"].include?(scopes&.first) and RequestStore.store[:sso] and RequestStore.store[:google_oauth2]
  end

  def model
    User
  end

  def authenticate

    code = params[:auth_data].split('&').find { |item|
      item.include?('code=')
    }&.split('=')&.last

    return if code.blank?

    id_token = get_access_token(code)
    return if id_token.blank?

    data = JWT.decode(id_token, nil, false).first.with_indifferent_access

    self.user_info = {}
    self.user_info[:email] = data[:email]
    user = User.where(active: true).find_by(email: user_info[:email])
    fail_with_event :on_blank_username, "Invalid username"
    if user.present?
      self.user_info[:user] = user
      self.user_info[:company_id] = user&.company_id
      self.user_info[:exp] = data[:exp]
      params[:user] = user
      self.user_info[:email_verified] = data[:email_verified]

      toggle = AuthenticationToggle.new(user)

      unless toggle.sso_google_enabled?
        fail_with_event :on_google_oauth, "Google SSO is not enabled for your account."
      end

      fail_with_event :on_inactive_user, "User Inactive"
      fail_with_event :on_expired_token, "Token Expired"

      # create a session
      email_verified = self.user_info[:email_verified]
      if email_verified
        self.authenticated_user = unauthenticated_user
      else
        fail_with_event :on_invalid_session, "Invalid login details given. Please contact your system administrator"
      end
    end
  end

  def unauthenticated_user
    raise "Model has not been defined" if model.nil?

    self.unauthenticated_user_obj ||= model.find_for_database_authentication(username: username, company_id: self.user_info[:company_id])
  end

  def on_invalid_session(message)
    unless self.user_info[:email_verified]
      params[:message] = "Invalid login details"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_expired_token(message)
    unless self.user_info[:exp] > Time.now.to_i
      params[:message] = "Token Expired"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_google_oauth(message)
    params[:message] = message
    UserSessions::Create.(:failed, params)
  end

  def username
    self.user_info[:email]
  end

  def on_blank_username(message)
    if username.blank?
      params[:message] = message || "Invalid username"
      UserSessions::Create.(:failed, params)
    end
  end

  def on_inactive_user(message)
    unless self.user_info[:user].status == 'Active' || self.user_info[:user].active
       params[:message] = message || "User Inactive"
       UserSessions::Create.(:failed, params)
    end
  end

  def on_success(message)
    result = Gatekeeper::Event.(:user_login_success, user: self.unauthenticated_user, username: username, ip: request.remote_ip)
    unless result.success?
      params[:user] = u
      params[:message] = result.message
      UserSessions::Create.(:blocked, params)
      block
    end
  end

  #  {"iss"=>"accounts.google.com",
  #  "azp"=>"307602140088-5aotklsei00379ioe94ebua3ge9nlv3s.apps.googleusercontent.com",
  #  "aud"=>"307602140088-5aotklsei00379ioe94ebua3ge9nlv3s.apps.googleusercontent.com",
  #  "sub"=>"109050515642264867674",
  #  "hd"=>"finly.io",
  #  "email"=>"prakash.thakur@finly.io",
  #  "email_verified"=>true,
  #  "at_hash"=>"lS1XKK1SThK3fsP8TGJZug",
  #  "name"=>"Prakash Thakur",
  #  "picture"=>
  #   "https://lh4.googleusercontent.com/-OceF5KtWAls/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuckId3mBT52mdG5nWY5-Zo7HVmU1OA/s96-c/photo.jpg",
  #  "given_name"=>"Prakash ",
  #  "family_name"=>"Thakur",
  #  "locale"=>"en",
  #  "iat"=>1615543580,
  #  "exp"=>1615547180,
  #  "jti"=>"1d456b46b3b964def7c7c2c782ed39d782faf90a"
  # }

  def get_access_token(code)
    client_id = Rails.application.config_for(:sso_provider_credentials)[:omniauth][:google][:client_id]
    client_secret = Rails.application.config_for(:sso_provider_credentials)[:omniauth][:google][:secret_id]
    redirect_uri = "#{Rails.application.config_for(:sso_provider_credentials)[:omniauth][:google][:base_url]}/auth/google_oauth2/callback"

    url = URI("https://oauth2.googleapis.com/token")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.body = "grant_type=authorization_code&code=#{code}&redirect_uri=#{redirect_uri}&client_id=#{client_id}&client_secret=#{client_secret}"
    response = https.request(request)

    puts response.read_body
    json_value = JSON.parse(response.read_body)
    id_token = json_value['id_token']
    id_token
  end

end
