class Category::Base < BaseOperation

  attr_accessor :categories, :purpose_id, :company, :parent_type_id, :custom_fields

  class Category::Base::CategoriesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :categories, :custom_fields

    def init
      self.categories = params[:categories]
      self.custom_fields = params[:custom_fields]
    end
  end

  def process
    self.categories = self.company.categories.with_purpose(self.purpose_id)
    self.custom_fields = self.company.field_configurations.with_parent_type(self.parent_type_id)
  end

  def success
    params[:categories] = self.categories
    params[:custom_fields] = self.custom_fields
    Category::Base::CategoriesPresenter.new(user, params, messages)
  end

end
