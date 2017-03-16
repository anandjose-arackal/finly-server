class PerDiemsController < ApplicationController

  def show

  end

  def create
    @result = ExpenseTypes::ExPerDiem::Create.(user, params)
    respond
  end

  def update
    @result = ExpenseTypes::ExPerDiem::Update.(user, params)
    respond
  end

  def index

  end

  def destroy
    @result = ExpenseTypes::ExPerDiem::Destroy.(user, params)
    respond
  end
end
