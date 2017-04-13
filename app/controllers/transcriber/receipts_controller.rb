class Transcriber::ReceiptsController < ApplicationController


  before_action :authenticate_user!
  allow_oauth!
  # before_action :transcriber_accounts

  def show

  end

  def index
    @result = Transcriber::Receipts::Index.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end


  private


end
