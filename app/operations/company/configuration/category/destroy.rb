class Company::Configuration::Category::Destroy < Company::Configuration::Category::Base
  attr_accessor :category, :destroy

  def pre_validate
    unless params[:id].present? or params[:category_id].present?
      add_message :error, 'Category ID not found'
    end
  end

  def init
    super
    id = (params[:id] or params[:category_id])
    self.category = self.categories.with_id(id).first rescue nil if id.present?
    return unless self.category.present?
    self.destroy = !(self.category.name == 'Personal' or self.category.name == 'Other')
  end

  def validate
    unless self.category.present?
      add_message :error, 'Category not found'
    end
  end

  def process
    if self.destroy
      unless self.category.update_attributes(active: false)
        add_message :error, self.category.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, 'Category destroyed'
  end

end