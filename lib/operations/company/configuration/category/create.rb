class Company::Configuration::Category::Create < Company::Configuration::Category::Base
  attr_accessor :category, :category_params

  def pre_validate
    unless params[:name].present?
      errors << 'Name of the category cannot be blank'
    end
  end

  def init
    super
    id = (params[:id].present? or params[:category_id])
    self.category = self.categories.with_id(id).first rescue nil if id.present?
  end

  def process
    if self.category.present?
      self.category.active = true
    else
      self.category = self.categories.build(company_id: user.company_id, name: category_params[:name])
    end
    unless category.save
      errors << category.errors.full_messages
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end