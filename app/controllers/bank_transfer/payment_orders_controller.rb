# currently this controller is only for admins of companies

class BankTransfer::PaymentOrdersController < ApplicationController

  before_action {finly_authorize! :web}

  def process_file
    @result = BankTransfer::YesBank::ParseFile.(current_user, params)
    respond
  end

  def create
    @result = BankTransfer::YesBank::Create.(current_user, params)
    respond
  end

  def index
    @result = BankTransfer::YesBank::Index.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::YesBank::Show.(current_user, params)
    respond
  end

  # the operation used to cancel the particular payment order
  def destroy
    @result = BankTransfer::YesBank::Cancel.(current_user, params)
    respond
  end

  # returns the Yes Bank Account Balance for the given account
  def balance
    @result = AccountManager::Balance::Check.(current_company.yes_bank_company_account, params)
    respond
  end
end
