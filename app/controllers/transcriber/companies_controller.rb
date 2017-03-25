class Transcriber::CompaniesController < ApplicationController

  before_action :authenticate_user!
  before_action :transcriber_accounts
  allow_oauth!

  def index
    @companies = Company.ocr_enabled
  end

  def show
    @result = Transcriber::Receipts::Index.(current_user, params)
    if @result.success?
      render 'transcriber/receipts/index'
    else
      flash[:error] = @result.messages[:error]
      redirect_to root_url
    end
  end

  private

  # todo - remove admin after testing
  def transcriber_accounts
    unless current_user.company_id == Company.find_by(name: "Transcriber") || current_user.email == 'admin@finlytest.io'
      flash[:error] = "You are not authorized to perform this action"
      redirect_to root_url
    end
  end
end
