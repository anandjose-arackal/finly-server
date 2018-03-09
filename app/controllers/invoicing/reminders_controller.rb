class Invoicing::RemindersController < ApplicationController

  def create
    @result = Invoicing::Company::Reminders::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Invoicing::Company::Reminders::Index.(current_user, params)
    respond
  end

  def update
    @result = Invoicing::Company::Reminders::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end