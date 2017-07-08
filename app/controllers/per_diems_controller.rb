class PerDiemsController < ApplicationController


  before_action :doorkeeper_authorize!

  def show

  end

  def create
    @result = ExpenseTypes::ExPerDiem::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages
    else
      respond response: :failure, message: @result.messages
    end
  end

  def update
    @result = ExpenseTypes::ExPerDiem::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages
    else
      respond response: :failure, message: @result.messages
    end
  end

  def index

  end

  def destroy
    @result = ExpenseTypes::ExPerDiem::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages
    else
      respond response: :failure, message: @result.messages
    end
  end
end
