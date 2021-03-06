class SecurityPolicy::Enforcers::BrowserUserAgent < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :browser_user_agent

  def otp_verify?(options = {})
    fetch(:browser, :user_agent, :otp_verify).include?(true)
  end

end