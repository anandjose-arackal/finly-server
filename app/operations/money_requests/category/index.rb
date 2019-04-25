class MoneyRequests::Category::Index < MoneyRequests::Category::Base
  attr_accessor :money_request_item_categories

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.money_request_item_categories = user.company.money_request_item_categories
  end

  def success
    params[:money_request_item_categories] = self.money_request_item_categories.active
    MoneyRequests::Category::Index::SuccessPresenter.new(user, params, messages)
  end

  class MoneyRequests::Category::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request_item_categories

    def init
      self.money_request_item_categories = params[:money_request_item_categories]
    end

  end

end