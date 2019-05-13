class SecurityPolicy::Enforcers::Gatekeeper < SecurityPolicy::Enforcers::Base

  def enabled?(options = {})
    Rails.env.production? and user.company_id != 2
  end

end