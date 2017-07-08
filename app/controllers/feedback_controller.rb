class FeedbackController < ApplicationController

  before_action :doorkeeper_authorize!

  def create
    @result = Feedback::Create.(current_user, params)
    respond response: @result.success? ? :success : :failure
  end

end
