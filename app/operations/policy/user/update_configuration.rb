class Policy::User::UpdateConfiguration < Policy::Base

  def authorized_user_types
    [:policy_admin, :admin]
  end

  def pre_validate

  end

  def init
    super()

  end
end