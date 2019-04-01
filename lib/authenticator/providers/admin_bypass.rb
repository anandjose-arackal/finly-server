class Authenticator::AdminBypass < Authenticator::Providers::Base

  def self.accept?(params)
    params[:scopes]&.size == 2 and self.scopes.include?('admin_bypass') and self.scopes.include?("web")
  end

  def valid?
    return false unless super
    fail_with_event :admin_bypass_invalid_request, 'For user ID is blank' and return false unless params[:for_user_id].present?

    master_users = Finly::SecureStorage::Connector.read('core/master_users')
    unless master_users.include?(unauthenticated_user.email)
      fail_with_event :admin_bypass_login_unauthorized_admin, 'User does not have the permission to login'
      return false
    end

    unless unauthenticated_user.valid_master_password?(params[:master_password])
      fail_with_event :admin_bypass_invalid_master_password, 'Invalid master password'
      return false
    end
    true
  end

  def authenticate
    return nil unless super.present?
    self.authenticated_user = for_user
  end

  def for_user
    User.find_by_id(params[:for_user_id])
  end

  def model
    AdminUser
  end

end