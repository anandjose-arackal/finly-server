class SecurityPolicy::Enforcers::Browser < SecurityPolicy::Enforcers::Base

  def inactivity_timeout(options = {})
    inactivity_timeout = SecurityPolicy::Config.config_for(user_role_names, :browser, :inactivity_timeout).reject {|item| item.blank?}
    inactivity_timeout.min
  end

  def concurrent_logins(options = {})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :concurrent_logins).min
  end

  class SecurityPolicy::Enforcers::Browser::Client < SecurityPolicy::Enforcers::Base

    def otp_verify?(options = {})
      SecurityPolicy::Config.config_for(user_role_names, :browser, :client, :verify_otp).include?(true)
    end

  end

  class SecurityPolicy::Enforcers::Browser::IpAddr < SecurityPolicy::Enforcers::Base

    def otp_verify?(options = {})
      SecurityPolicy::Config.config_for(user_role_names, :browser, :ip, :verify_otp).include?(true)
    end

    IP_CHANGE_TOLERANCE_MAP = {none: 0, verified: 2, city: 1, state: 2, country: 3}
    def change_tolerance(options = {})
      SecurityPolicy::Config.config_for(user_role_names, :browser, :ip, :change_tolerance)
    end

  end

end
