class Settlement::MoneyRequest::Unapproved < MoneyRequest::Base
  attr_accessor :money_request

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
  end

  def validate
    if money_request.credited?
      messages[:error] << 'Money Request has already been processed'
    end
    unless money_request.processing?
      messages[:error] << 'Cannot reduce pending cash advance as the request in not in processing state'
    end
  end

  def process
    unless money_request.accounted
      return
    end

    total_amount = money_request.total_amount
    currency = Currency.first
    user.balance_sheet.subtract_pending_advance total_amount, currency
    unless money_request.update_attribute(:accounted, false)
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