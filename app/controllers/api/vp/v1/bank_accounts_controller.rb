class Api::Vp::V1::BankAccountsController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  def disable
    @result = BankTransfer::BankAccounts::Disable.(current_user, params)
    respond
  end
  
end
