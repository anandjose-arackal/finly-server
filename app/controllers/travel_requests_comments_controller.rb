class TravelRequestsCommentsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def create
    @result = TravelRequests::Comment::Create.(current_user, params)
    respond response: (@result.success? ? :success : :failure)
  end

end
