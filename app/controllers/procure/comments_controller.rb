class Procure::CommentsController < BaseControllers::WebBase

  def create
    @result = Procurements::Comments::Create.(current_user, params)
    respond
  end
end
