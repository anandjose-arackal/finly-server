class Mobile::V2::ExpensesController < ApplicationController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :mobile}

  def available_expense_types
    @result = User::AvailableExpenseTypes::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

end
