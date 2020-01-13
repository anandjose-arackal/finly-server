class Procure::CommentsController < BaseControllers::WebBase

  def create
    @result = Procurements::Comments::Create.(current_user, params)
    respond
  end

  def index
    @result = Procurements::Comments::Index.(current_user, params)
    respond
  end
end
