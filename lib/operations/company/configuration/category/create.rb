class Company::Configuration::Category::Create < Company::Configuration::Category::Base
  attr_accessor :category

  def pre_validate
    unless params[:name].present?
      messages[:error] << 'Name of the category cannot be blank'
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
      self.category = self.categories.build(company_id: user.company_id, name: params[:name])
    end
    unless category.save
      messages[:error] << category.errors.full_messages
    end
  end
end