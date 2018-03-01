class Api::Vp::BankTransfer::BankPaymentRequestsController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :web }

  def create
    @result = BankTransfer::PaymentRequest::Create.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::PaymentRequest::Show.(current_user, params)
    respond
  end

  def credit
    @result = BankTransfer::PaymentRequest::Review::Credit.(current_user, params)
    respond
  end

end