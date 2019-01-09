class BankTransfer::AccountOwnersController < ApplicationController

  before_action {finly_authorize! :web}

  def index
    @result = BankTransfer::AccountOwners::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::AccountOwners::Count.(current_user, params)
    render json: @result.as_json
  end

  def show
    @result = BankTransfer::AccountOwners::Show.(current_user, params)
    respond
  end

  def search
    @result = BankTransfer::AccountOwners::Index.(current_user, params)
    respond
  end

  def bank_accounts
    @result = BankTransfer::AccountOwners::BankAccounts.(current_user, params)
    respond
  end

end