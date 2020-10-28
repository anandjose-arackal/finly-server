class ApprovalMatrixController < BaseControllers::WebBase

  def index
    @result = ApprovalMatrix::Index.(current_user, params)
    respond
  end

end