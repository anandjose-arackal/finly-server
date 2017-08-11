class BankTransfer::BankAccountsController < ApplicationController

  before_action {finly_authorize! :web}

  def create
    @result = BankTransfer::BankAccount::Create.(cucurrent_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = BankTransfer::BankAccount::Index.(current_user, params)
    respond
  end

  def show

  end

  def destroy

  end
end