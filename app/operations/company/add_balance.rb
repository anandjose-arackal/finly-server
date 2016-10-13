class Coompany::AddBalance < Company::Base

  def pre_validate
    messages[:error] << "Invalid input. Please try again"
  end

  def authorized_user_types
    [:company_admin]
  end

  def init

  end
end
