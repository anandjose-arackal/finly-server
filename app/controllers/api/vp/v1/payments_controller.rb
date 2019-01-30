class Api::Vp::V1::PaymentsController < ApplicationController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }

  def index
    @result = BankTransfer::Payments::Index.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::PaymentRequest::Show.(current_user, params)
    respond
  end
end
