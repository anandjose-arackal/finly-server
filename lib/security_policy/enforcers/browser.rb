class SecurityPolicy::Device::Browser < SecurityPolicy::Enforcers::Base

  def otp_verify?(user_device)
    SecurityPolicy::Config.config_for(user, :device, :browser, :otp_verification).include?(true)
  end

end
