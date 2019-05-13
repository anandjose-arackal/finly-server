class SecurityPolicy::Enforcers::Gatekeeper < SecurityPolicy::Enforcers::Base

  def enabled?(options = {})
    Rails.env.production? and not user.company.test_account
  end

end