class SecurityPolicy::Enforcers::Browser < SecurityPolicy::Enforcers::Base

  def otp_verify_client?(options={})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :client, :verify_otp).include?(true)
  end

  def otp_verify_ip?(options={})
    SecurityPolicy::Config.config_for(user_role_names, :browser, :ip, :verify_otp).include?(true)
  end

  def inactivity_timeout(options={})
    inactivity_timeout = SecurityPolicy::Config.config_for(user_role_names, :browser, :inactivity_timeout).reject {|item| item.blank?}
    inactivity_timeout.min
  end

end
