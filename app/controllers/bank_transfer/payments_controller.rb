class BankTransfer::PaymentsController < ApplicationController

  def index
    @result = BankTransfer::Payments::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::Payments::Count.(current_user, params)
    render json: @result.as_json
  end

  def show

  end

  def retry
    @result = BankTransfer::Payments::Retry.(params[:payment_id])
    respond
  end
end