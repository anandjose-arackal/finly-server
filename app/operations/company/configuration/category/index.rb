class Company::Configuration::Category::Index < Company::Configuration::Category::Base

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def process
    self.categories = current_company.categories.active.with_purpose(Purpose.category_purpose_from_application(RequestStore.store[:current_app]))
  end

  def success
    params[:categories] = self.categories
    Company::Configuration::Category::Base::Presenter.new(user, params, messages)
  end

end