class Transcriber::ReceiptsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!
  before_action :transcriber_accounts

  def create_expense
    @result = Transcriber::Expenses::Create.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.html {
          flash[:success] = "Receipt transcribed"
          redirect_to request.referrer
        }
        format.json {
          respond response: :success, message: @result.messages[:success]
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @result.messages[:error]
          redirect_to request.referrer
        }
        format.json {
          respond response: :failure, message: @result.messages[:error]
        }
      end
    end
  end

  def update_expense
    @result = Transcriber::Expenses::Update.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.html {
          flash[:success] = "Receipt transcribed"
          redirect_to request.referrer
        }
        format.json {
          respond response: :success, message: @result.messages[:success]
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @result.messages[:error]
          redirect_to request.referrer
        }
        format.json {
          respond response: :failure, message: @result.messages[:error]
        }
      end
    end
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
