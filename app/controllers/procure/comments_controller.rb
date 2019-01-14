class Procure::CommentsController < BaseControllers::WebBase
  before_action -> {finly_authorize! :web}

  def create
    @result = Procurements::Comments::Create.(current_user, params)
    respond
  end
end
