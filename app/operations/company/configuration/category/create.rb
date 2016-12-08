class Company::Configuration::Category::Create < Company::Configuration::Category::Base
  attr_accessor :category

  def pre_validate
    unless params[:category][:name].present?
      messages[:error] << 'Name of the category cannot be blank'
    end
  end

  def init
    super
    # here we need all categories, not just inactive ones
    self.category = user.company.categories.with_name(category_params[:name]).first rescue nil
  end

  def process
    if self.category.present?
      self.category.active = true
    else
      self.category = self.categories.build(company_id: user.company_id, name: category_params[:name])
    end
    unless category.save
      messages[:error] = category.errors.full_messages
    end
  end

  def post_process
    messages[:success] << "Category added"
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end