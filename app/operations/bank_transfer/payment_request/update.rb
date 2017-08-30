# operation that updates a particular payment order from the changes that the user mentions in the beginning of the
class BankTransfer::PaymentRequest::Update < BankTransfer::PaymentRequest::Base
  attr_accessor :response_presenter

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading request'
      return
    end
  end

  def process
    order_data = params[:payment_order]
    scheduled_at = params[:scheduled_at]
    initiating_account_type = params[:initiating_account_type]
    self.response_presenter = BankTransfer::PaymentRequest::Process.(user, {scheduled_at: scheduled_at,
                                                                    payment_order: order_data,
                                                                    initiating_account_type: initiating_account_type})
    unless self.response_presenter.success?
      add_message :error, self.response_presenter.messages[:error]
    end
  end

  def success
    self.response_presenter
  end

end
