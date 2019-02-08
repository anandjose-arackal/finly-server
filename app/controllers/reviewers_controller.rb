class ReviewersController < ApplicationController
  before_action -> { finly_authorize! :web }

  def create
    @result = ReviewalLevels::Reviewers::Create.(current_user, params)
    respond
  end

  def update
    @result = ReviewalLevels::Reviewers::Update.(current_user, params)
    respond
  end

  def destroy
    @result = ReviewalLevels::Reviewers::Destroy.(current_user, params)
    respond
  end
end