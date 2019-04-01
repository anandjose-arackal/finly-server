class Authenticator::Providers::Admin < Authenticator::Providers::Base

  def self.accept?(params)
    params[:scopes]&.size == 1 and self.scopes.include?('admin')
  end

  def model
    AdminUser
  end

end