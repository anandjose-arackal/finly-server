class FeedbackController < BaseControllers::WebBase


  def create
    @result = Feedback::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

end
