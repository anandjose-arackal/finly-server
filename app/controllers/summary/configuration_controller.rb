class Summary::ConfigurationController < BaseControllers::WebBase

  before_action -> { finly_authorize! :web }

  def index
    @result = SummaryMailer::Index.(current_user, params)
    respond
  end

  def admin_create
    @result = SummaryMailer::CompanyAdmin::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def admin_destroy
    @result = SummaryMailer::CompanyAdmin::Destroy.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def manager_create
    @result = SummaryMailer::Manager::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def manager_destroy
    @result = SummaryMailer::Manager::Destroy.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
