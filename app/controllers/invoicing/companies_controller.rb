class Invoicing::CompaniesController < BaseControllers::WebBase


  def withdraw_funds
    @result = Invoicing::Company::CreditsWithdrawal::WithdrawFunds.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  # this action shows the details of the current account and the balance that can be transferred back to their respective current accounts
  def show_credit_account
    @result = Invoicing::Company::CreditsWithdrawal::Show.(current_user, params)
    respond
  end

  # this action shows the history of transfers for this particular company
  def transfer_history
    @result = Invoicing::Company::CreditsWithdrawal::ShowHistory.(current_user, params)
    respond
  end



end
