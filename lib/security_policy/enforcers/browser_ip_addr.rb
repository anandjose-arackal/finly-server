class SecurityPolicy::Enforcers::BrowserIpAddr < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :browser_ip

  def otp_verify?(options = {})
    fetch(:browser, :ip, :otp_verify).include?(true)
  end

  def restriction(options = {})
    ip_restriction = fetch(:browser, :ip, :restrict)
    return nil if ip_restriction.blank?
    unless ip_restriction.is_a?(Array)
      ip_restriction = ip_restriction.split(',')
    end
    ip_restriction.flatten.uniq
  end

  # IP_CHANGE_TOLERANCE_MAP = {none: 0, verified: 2, city: 1, state: 2, country: 3}
  #
  # def change_tolerance(options = {})
  #   fetch(:browser, :ip, :change_tolerance)
  # end

end
