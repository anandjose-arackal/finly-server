class Api::Vp::V1::BankAccountsController < ApplicationController

  def disable
    @result = BankTransfer::BankAccounts::Disable.(current_user, params)
    respond
  end
  
end