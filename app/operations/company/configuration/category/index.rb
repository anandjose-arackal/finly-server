class Company::Configuration::Category::Index < Company::Configuration::Category::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def process
    self.categories = current_company.categories.with_purpose(Purpose.id_from_application_for(RequestStore.store[:current_app]))
  end

  def success
    params[:categories] = self.categories
    Company::Configuration::Category::Base::Presenter.new(user, params, messages)
  end

end