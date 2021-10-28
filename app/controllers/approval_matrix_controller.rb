class ApprovalMatrixController < BaseControllers::WebBase

  def index
    @result = ApprovalMatrix::Index.(current_user, params)
    respond
  end

  def vp_workflow_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

end