# this operation will destroy a payment request that is generated in the vendor payment system
# so that the details are destroyed
class BankTransfer::PaymentRequest::Destroy < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = user.bank_payment_requests.find_by(id: id)
  end

  def validate
    unless bank_payment_request.owner_id == user.id
      add_message :error, "Only owners can destroy payment orders"
      return
    end
  end

  def process
    unless bank_payment_request.destroy
      add_message :error, bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment Order destroyed"
  end
end