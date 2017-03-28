class Transcriber::ReceiptsController < ApplicationController

  before_action :authenticate_user!
  before_action :transcriber_accounts
  allow_oauth!

  def create_expense
    @result = Transcriber::Expenses::Create.(current_user, params)
    if @result.success?
      flash[:success] = "Receipt transcribed"
    else
      flash[:error] = @result.messages[:error]
    end
    redirect_to request.referrer
  end

  def update_expense
    @result = Transcriber::Expenses::Update.(current_user, params)
    if @result.success?
      flash[:success] = "Expense Updated"
    else
      flash[:error] = @result.messages[:error]
    end
    redirect_to request.referrer
  end

  def show
  end

  # def receipts
  #   @result = Transcriber::Receipt::Index.(current_user, params)
  #   respond
  # end

  private

  # todo - remove admin after testing
  def transcriber_accounts
    unless current_user.company_id == Company.find_by(name: "Transcriber") || current_user.email == 'admin@finlytest.io'
      flash[:error] = "You are not authorized to perform this action"
      redirect_to root_url
    end
  end
end
