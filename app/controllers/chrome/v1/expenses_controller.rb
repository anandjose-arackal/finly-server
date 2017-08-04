class Chrome::V1::ExpensesController < ApplicationController

  before_action -> { finly_authorize! :chrome}

  def create
    formatted_param = RequestFormatter::ApiParser::ChromeParser::V1::Expenses::Parse.(current_user, params)&.formatted_request
    @result = Expense::Manual::Create.(current_user, formatted_param)
    respond response: (@result&.success? ? :success : :failure)
  end

  def update
    formatted_param = RequestFormatter::ApiParser::ChromeParser::V1::Expenses::Parse.(current_user, params)&.formatted_request
    @result = Expense::Manual::Update.(current_user, formatted_param)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
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
