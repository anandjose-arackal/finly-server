class Summary::CompanyAdminController < ApplicationController

  before_action -> { finly_authorize! :web }

  def create
    @result = SummaryMailer::CompanyAdmin::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = SummaryMailer::CompanyAdmin::Index.(current_user, params)
    respond
  end

  def destroy
    @result = SummaryMailer::CompanyAdmin::Destroy.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
