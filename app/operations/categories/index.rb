class Categories::Index < Categories::Base

  attr_accessor :purpose

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
  end

  def init
    self.purpose = params[:purpose]
  end

  def process
    self.categories = user.company.categories.active
  end

  def success
    params[:categories] = self.categories
    Categories::Base::CategoriesPresenter.new(user, params, messages)
  end

end