class SecurityPolicy::Enforcers::Gatekeeper < SecurityPolicy::Enforcers::Base

  bus SecurityPolicy::Manager
  subscribe :gatekeeper

  def enabled?(options = {})
    true
    # Rails.env.production? and not user.company.test_account
  end

end