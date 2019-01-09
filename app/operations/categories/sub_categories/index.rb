# this operation will return the sub categories for a particular category given its id
class Categories::SubCategories::Index < Categories::Base

  attr_accessor :category, :sub_categories

  def init
    id = params[:id] || params[:category_id]
    self.category = current_company.categories.active.find_by(id: id)
  end

  def process
    self.sub_categories = self.category.children
    if expense_management?
      self.sub_categories = self.sub_categories.expense_management_only
    end
  end

  def success
    params[:categories] = self.sub_categories
    Categories::Base::CategoriesPresenter.new(user, params, messages)
  end
end