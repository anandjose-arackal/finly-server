class Invoicing::CompaniesController < ApplicationController

  def withdraw_funds
    @result = Invoicing::Company::WithdrawFunds.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end