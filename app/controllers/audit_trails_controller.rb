class AuditTrailsController < BaseControllers::WebBase

  def index
    @result = AuditTrails::Index.(current_user, params)
    respond
  end

end
