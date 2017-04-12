Opro.setup do |config|
  ## Configure the auth_strategy or use set :login_method, :logout_method, & :authenticate_user_method
  config.auth_strategy = :devise

  ## Add or Remove Application Permissions
  # Read permission (any request with [GET]) is turned on by default
  # Write permission (any request other than [GET]) is requestable by default
  # Custom permissions can be configured by adding them to `config.request_permissions`
  # You can then require that permission on individual actions by calling
  # `require_oauth_permissions` in the controller
  config.request_permissions = [:write]

  ## Refresh Token Config
  # uncomment `config.require_refresh_within` to require refresh tokens
  # this will expire tokens within the given time duration, having it enabled
  # is more secure, but harder to use.
  config.require_refresh_within = 1.month

  ## Allow Password Exchange
  # You can allow client applications to exchange a user's credentials
  # password, etc. for an access token.
  # Caution: This bypasses the traditional OAuth flow
  # as a result users cannot opt out of client permissions, all permissions are granted
  config.password_exchange_enabled = true

  config.find_user_for_auth do |controller, params|
    if params[:controller].include?('admin')
      return false if params[:email].blank? or params[:password].blank?
      admin_user = AdminUser.find_for_database_authentication(params) rescue nil
      return false if admin_user.blank?
      admin_user.valid_password?(params[:password]) ? admin_user : false
    else
      return false if params[:email].blank? or params[:password].blank?
      user = User.find_for_database_authentication(params) rescue nil
      return false if user.blank?
      user.valid_password?(params[:password]) ? user : false
    end
  end

end