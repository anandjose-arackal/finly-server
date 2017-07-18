class FeedbackController < ApplicationController

  before_action -> { doorkeeper_authorize! :web}

  def create
    @result = Feedback::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

end
