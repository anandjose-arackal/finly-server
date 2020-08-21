class ImportJobsController < BaseControllers::WebBase

  def index
    @result = ExportManager::Jobs::Index.(current_user, params)
    respond
  end

end
