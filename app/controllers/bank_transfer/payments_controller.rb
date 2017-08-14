class BankTransfer::PaymentsController < ApplicationController

  def index
    @result = BankTransfer::Payments::Index.(current_user, params)
    respond
  end

  def show

  end
end