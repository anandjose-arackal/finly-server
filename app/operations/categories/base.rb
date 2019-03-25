class Categories::Base < BaseOperation

  attr_accessor :categories, :purpose, :company, :parent_type_id, :custom_fields

  #Jugaad for swiggy as they do not have access to expense management
  # and below roles are scoped to expense management
  # def authorized_user_types
  #   [:employee, :manager, :finance_manager, :company_admin, :auditor]
  # end

  class Categories::Base::CategoriesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :categories, :custom_fields

    has_scope :filter_search

    def init
      self.categories = apply_scopes(params[:categories], params)
      self.custom_fields = params[:custom_fields]
    end
  end

  def process
    self.categories = self.company.categories
    self.custom_fields = self.company.field_configurations.with_parent_type(self.parent_type_id)
  end

  def success
    params[:categories] = self.categories
    params[:custom_fields] = self.custom_fields
    Categories::Base::CategoriesPresenter.new(user, params, messages)
  end

end