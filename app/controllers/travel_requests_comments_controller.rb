class TravelRequestsCommentsController < BaseControllers::WebBase


  def create
    @result = TravelRequests::Comment::Create.(current_user, params)
    respond response: (@result.success? ? :success : :failure)
  end

end
