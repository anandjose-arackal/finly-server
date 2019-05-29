class SecurityPolicy::Enforcers::BrowserUserAgent < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :browser_user_agent

  def otp_verify?(options = {})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :client, :otp_verify).include?(true)
  end

end