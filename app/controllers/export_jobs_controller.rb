class ExportJobsController < BaseControllers::WebBase

  def index
    @result = ExportManager::Index.(current_user, params)
    respond
  end

end
