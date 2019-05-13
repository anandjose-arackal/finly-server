class SecurityPolicy::IpAddr < SecurityPolicy::Device::Base

  def self.otp_verify?(user, ip)
    SecurityPolicy::Config.config_for(user, :ip, :otp_verification).include?(true)
  end

  # Todo scoping IP to company
  def self.permitted?(user, ip)
    true
  end

end