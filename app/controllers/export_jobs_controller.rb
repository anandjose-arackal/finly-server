class ExportJobsController < BaseControllers::WebBase

  def index
    @result = ExportManager::Jobs::Index.(current_user, params)
    respond
  end

  def export_jobs_config
    Personalizer::Adapters::Company137::ExportTemplates137::TallyJournalTemplate
    @result = ExportManager::Config.(current_user, params)
    respond
  end

  def create
    @result = ExportManager::RequestHandler.(current_user, params)
    respond
  end

end
