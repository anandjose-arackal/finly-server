class Settlement::MoneyRequest::Approved < MoneyRequest::Base
  attr_accessor :money_request, :selected_user

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def init
    self.money_request = params[:money_request]
    if self.money_request
      self.selected_user = money_request.user
    end
  end

  def validate
    if money_request.credited?
      messages[:error] << 'Money Request has already been processed'
    end
    unless money_request.approved?
      messages[:error] << 'Error while adding money to pending cash advance'
    end
    if money_request.accounted
      messages[:error] << 'Advance Request has already been accounted'
    end
  end

  def process
    total_amount = money_request.total_amount
    currency = Currency.first
    selected_user.balance_sheet.add_pending_advance total_amount, currency
    unless money_request.update_attribute(:accounted, true)
      messages[:error] = money_request.errors.full_messages
    end
  end

  def post_process
    # mailer
  end

  def success
    money_request
  end
end