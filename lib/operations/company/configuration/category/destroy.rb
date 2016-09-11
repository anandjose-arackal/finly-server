class Company::Configuration::Category::Destroy < Company::Configuration::Category::Base
  attr_accessor :category

  def pre_validate
    unless params[:id].present? or params[:category_id].present?
      errors << 'Category ID not found'
    end
  end

  def init
    super
    id = (params[:id].present? or params[:category_id])
    self.category = self.categories.with_id(id).first rescue nil if id.present?
  end

  def validate
    unless self.category.present?
      errors << 'Category not found'
    end
  end

  def process
    unless self.category.update_attribute(active: false)
      errors << self.category.errors.full_messages
    end
  end

end