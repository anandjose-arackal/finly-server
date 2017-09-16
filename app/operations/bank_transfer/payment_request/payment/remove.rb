class BankTransfer::PaymentRequest::Payment::Remove < BankTransfer::PaymentRequest::Payment::Base

  attr_accessor :removed_payment

  def init
    super
    id = params[:payment_id]
    self.removed_payment = payment_order&.payments.find_by(id: id)
  end

  def process
    unless self.removed_payment.destroy
      add_message :error, self.removed_payment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment successfully removed"
  end
end