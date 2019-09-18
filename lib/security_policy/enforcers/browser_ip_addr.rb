class SecurityPolicy::Enforcers::BrowserIpAddr < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :browser_ip

  def otp_verify?(options = {})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :ip, :otp_verify).include?(true)
  end

  # IP_CHANGE_TOLERANCE_MAP = {none: 0, verified: 2, city: 1, state: 2, country: 3}
  #
  # def change_tolerance(options = {})
  #   SecurityPolicy::Config.config_for(user_role_names, :browser, :ip, :change_tolerance)
  # end

end
