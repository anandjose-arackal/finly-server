# operation that updates a particular payment order from the changes that the user mentions in the beginning of the
class BankTransfer::YesBank::Update < BankTransfer::YesBank::Base
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
    self.response_presenter = BankTransfer::YesBank::Process.(user, scheduled_at: scheduled_at,
        payment_order: order_data)
    unless self.response_presenter.success?
      add_message :error, self.response_presenter.messages[:error]
    end
  end

  def success
    self.response_presenter
  end

end
