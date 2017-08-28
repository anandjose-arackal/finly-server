class BankTransfer::PaymentRequest::Review::TakeControl < BankTransfer::PaymentRequest::Review::Base

  def init
    super
  end

  def validate
    unless user.vendor_payments_admin?
      add_message :error, "Only admins can take control of a report"
      return
    end
  end

  def process

  end

  def post_process
    add_message :success, "Report taken control of successfully!"
  end


end