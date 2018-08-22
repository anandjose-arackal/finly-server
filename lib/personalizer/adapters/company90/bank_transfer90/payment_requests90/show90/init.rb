class Personalizer::Adapters::Company90::BankTransfer90::PaymentRequests90::Show90::Init < Personalizer::Adapters::Base
  attr_accessor :bank_payment_request
  def init
    id = params[:id] || params[:payment_request_id]

    company_user_ids = user.company.users.pluck(:id)

    self.bank_payment_request = BankPaymentRequest.with_user(company_user_ids).find_by id: id

    if self.bank_payment_request.present?
      op_instance.bank_payment_request = self.bank_payment_request
    end
  end
end