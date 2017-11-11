class Company::Configuration::Category::Create < Company::Configuration::Category::Base
  attr_accessor :category, :purpose_id

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super
    # here we need all categories, not just inactive ones
    self.category = user.company.categories.with_name(category_params[:name]).first rescue nil
    self.purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
  end

  def process
    debugger
    if self.category.present?
      self.category.active = true
    else
      self.category = self.categories.build(company_id: user.company_id, name: category_params[:name], purpose_id: self.purpose_id)
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