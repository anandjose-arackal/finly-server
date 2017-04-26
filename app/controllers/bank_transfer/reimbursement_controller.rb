class BankTransfer::ReimbursementController < ApplicationController

  def create

  end

  def show
    @result = BankTransfer::Reimbursement::Show.(current_user, params)
    respond
  end

  def update

  end

end
