class Api::Vp::V1::PaymentsController < BaseControllers::ApiBase

  def index
    @result = BankTransfer::Payments::Index.(current_user, params)
    respond
  end

  def all_payments
    @result = BankTransfer::Payments::AllPayments.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::PaymentRequest::Show.(current_user, params)
    respond
  end
end
