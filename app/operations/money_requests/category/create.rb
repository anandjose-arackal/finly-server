class MoneyRequests::Category::Create < MoneyRequests::Category::Base
  attr_accessor :category_params, :money_request_item_category

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.money_request_item_category = user.company.money_request_item_categories.with_name(params[:name])&.first
    if money_request_item_category.blank?
      self.money_request_item_category = user.company.money_request_item_categories.build name: params[:name], active: true
    end
    self.money_request_item_category.active = true if self.money_request_item_category.present?
  end

  def validate
    unless self.money_request_item_category.valid?
      add_message :error, self.money_request_item_category.errors.full_messages
      return
    end
  end

  def process
    self.money_request_item_category.save
  end

end