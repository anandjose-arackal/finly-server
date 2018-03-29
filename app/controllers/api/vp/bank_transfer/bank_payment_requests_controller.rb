class Api::Vp::BankTransfer::BankPaymentRequestsController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }

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

  def initiate_payment
    @result = BankTransfer::PaymentRequest::ApiPayments::InitiatePayment.(current_user, params)
    respond
  end

  # this action will take a particular payment ID and return the status of that particular payment
  def payment_status
    @result = BankTransfer::PaymentRequest::ApiPayments::GetPaymentStatus.(current_user, params)
    respond
  end

end