class Chrome::V1::ExpensesController < ApplicationController

  allow_oauth!
  before_action :authenticate_user!

  def create
    formatted_param = RequestFormatter::ApiParser::ChromeParser::V1::Expenses::Parse.(current_user, params)&.formatted_request
    @result = Expense::Manual::Create.(current_user, formatted_param)
    respond response: (@result&.success? ? :success : :failure)
  end

  def update

  end

  def destroy
    @result = Expense::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
  end

  def configuration
    @result = User::AvailableExpenseTypes::Show.(current_user, params)
    respond
  end

end
