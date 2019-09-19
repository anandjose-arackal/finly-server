class Categories::Index < Categories::Base

  attr_accessor :purpose

  # def authorized_user_types
  #   [:employee, :manager, :finance_manager, :admin, :auditor, :vendor_payments_admin]
  # end

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
    self.vp_categories = self.categories.vendor_payments_only
    self.em_categories = self.categories.expense_management_only

    case RequestStore.store[:current_app]
    when 'vp', :vp
      self.categories = self.categories.vendor_payments_only
    when 'em', :em
      self.categories = self.categories.expense_management_only
    else
      self.categories = user.company.categories.active
    end

    # in org account, show all categories
    if RequestStore.store[:organization_account]
      self.categories = user.company.categories.active
    end

  end

  def success
    params[:categories] = self.categories
    params[:em_categories] = self.em_categories
    params[:vp_categories] = self.vp_categories
    Categories::Base::CategoriesPresenter.new(user, params, messages)
  end

end