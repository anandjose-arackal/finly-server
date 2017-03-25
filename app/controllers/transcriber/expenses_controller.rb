class Transcriber::ExpensesController < ApplicationController

  before_action :authenticate_user
  before_action :transcriber_accounts
  allow_oauth!

  def create
    @result = Transcriber::Expense::Create.(current_user, params)
    respond
  end

  def update
  end

  def show
  end

  def receipts
    @result = Transcriber::Receipt::Index.(current_user, params)
    respond
  end

  private

  def transcriber_accounts
    unless current_user.company_id == Company.find_by(name: "Transcriber")
      flash[:error] = "You are not authorized to perform this action"
      redirect_to root_url
    end
  end
end
