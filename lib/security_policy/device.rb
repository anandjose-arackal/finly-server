class SecurityPolicy::Device

  class SecurityPolicy::Device::Browser

    def self.otp_verify?(user, user_roles, user_device)
      SecurityPolicy::Config.config_for(user, :device, :browser, :otp_verification).include?(true)
    end

  end

end