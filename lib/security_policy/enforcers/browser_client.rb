class SecurityPolicy::Enforcers::BrowserClient < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :browser_client

  def inactivity_timeout(options = {})
    inactivity_timeout = SecurityPolicy::Config.config_for(user_role_names, :browser, :inactivity_timeout).reject {|item| item.blank?}
    inactivity_timeout.min
  end

  def concurrent_logins(options = {})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :concurrent_logins).min
  end

  def otp_verify?(options = {})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :client, :otp_verify).include?(true)
  end

end