class BankTransfer::BankAccountsController < ApplicationController

  before_action {finly_authorize! :web}

  def create
    @result = BankTransfer::BankAccounts::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = BankTransfer::BankAccounts::Index.(current_user, params)
    respond
  end

  def show

  end

  def destroy

  end

  def update
    @result = BankTransfer::BankAccounts::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end