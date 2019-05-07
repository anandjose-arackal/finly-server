class OrganizationAccount::Configuration::Update < OrganizationAccount::Configuration::Base

  attr_accessor :enforce_policy



  def init
    self.enforce_policy = params[:enforce_policy]
  end

  def process
    if enforce_policy.present?
      if user.company.enforce_policy.blank?
        user.company.create_enforce_policy(enabled: true)
      else
        user.company.enforce_policy.update(enabled: enforce_policy)
      end
    end
  end

  def post_process
    add_message :success, 'Organization account updated!'
  end

end