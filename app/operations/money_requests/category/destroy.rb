class MoneyRequests::Category::Destroy < MoneyRequests::Category::Base
  attr_accessor :money_request_category_items

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
    self.money_request_category_items = user.company.money_request_item_categories.with_id(params[:id])
  end

  def validate
    unless self.money_request_category_items.present?
      add_message :error, 'Money Request Category not found'
      return
    end
  end

  def process
    self.money_request_category_items.update_all(active: false)
  end

end