class Categories::Index < Categories::Base

  attr_accessor :purpose

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def process
    self.categories = user.company.categories.active.with_purpose(self.purpose)
  end

  def success
    params[:categories] = self.categories
    Categories::Base::CategoriesPresenter.new(user, params, messages)
  end

end