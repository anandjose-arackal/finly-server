class Company::Configuration::Category::Destroy < Company::Configuration::Category::Base
  attr_accessor :category

  def pre_validate
    unless params[:id].present? or params[:category_id].present?
      messages[:error] << 'Category ID not found'
    end
  end

  def init
    super
    id = (params[:id] or params[:category_id])
    self.category = self.categories.with_id(id).first rescue nil if id.present?
  end

  def validate
    unless self.category.present?
      messages[:error] << 'Category not found'
      return false
    end
    if category.name == "Other" or category.name == "Personal"
      messages[:error] << "Cannot destroy 'Other' or 'Personal' categories"
      return false
    end
  end

  def process
    unless self.category.update_attributes(active: false)
      messages[:error] = self.category.errors.full_messages
    end
  end

  def post_process
    messages[:success] << 'Category destroyed'
  end

end