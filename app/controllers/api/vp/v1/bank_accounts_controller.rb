class Api::Vp::V1::BankAccountsController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }

  def disable
    @result = BankTransfer::BankAccounts::Disable.(current_user, params)
    respond
  end
  
end