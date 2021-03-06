class SecurityPolicy::Enforcers::BrowserClient < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :browser_client

  def inactivity_timeout(options = {})
    inactivity_timeout = fetch(:browser, :inactivity_timeout).reject {|item| item.blank?}
    inactivity_timeout.min
  end

  def concurrent_logins(options = {})
    fetch(:browser, :concurrent_logins).min
  end

  def otp_verify?(options = {})
    fetch(:browser, :client, :otp_verify).include?(true)
  end

end