class Company::Configuration::Category::Index < Company::Configuration::Category::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

end