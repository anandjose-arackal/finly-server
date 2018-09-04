class ReviewersController < ApplicationController
  before_action -> { finly_authorize! :web }

  def create
    @result = ReviewalLevels::Reviewers::Create.(current_user, params)
    respond
  end
end