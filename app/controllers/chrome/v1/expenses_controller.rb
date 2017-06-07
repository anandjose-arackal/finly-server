class Chrome::V1::ExpensesController < ApplicationController

  allow_oauth!
  before_action :authenticate_user!

  def create

  end

  def show

  end

  def update

  end

  def destroy

  end

  def configuration
    @result = User::AvailableExpenseTypes::Show.(current_user, params)
    respond
  end

end
