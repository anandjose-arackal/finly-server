class AuditTrailsController < ApplicationController
  before_action -> { finly_authorize! :web}

  def index
    @result = AuditTrails::Index.(current_user, params)
    respond
  end

end
