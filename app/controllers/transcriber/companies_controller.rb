class Transcriber::CompaniesController < BaseControllers::AdminBase


  before_action -> { finly_authorize! :admin}
  # before_action :transcriber_accounts

  def index
    @companies = Company.ocr_enabled
  end

  def show

  end

  private

  # todo - remove admin after testing
  def transcriber_accounts
    unless current_user.company_id == Company.find_by(name: "Transcriber").id
      flash[:error] = "You are not authorized to perform this action"
      redirect_to root_url
    end
  end
end
