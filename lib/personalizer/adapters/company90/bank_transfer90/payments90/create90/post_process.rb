class Personalizer::Adapters::Company90::BankTransfer90::Payments90::Create90::PostProcess < Personalizer::Adapters::Base
  attr_accessor :bank_payment_request
  def init
    self.bank_payment_request = op_instance.bank_payment_request
  end

  def validate
    unless self.bank_payment_request.present?
      add_message :error, 'Bank payment request not found'
    end
  end

  def process
    p = {
        bank_payment_request_id: self.bank_payment_request.id
    }
    op = BankTransfer::PaymentRequest::Review::Submit.(user, p)
  end

end