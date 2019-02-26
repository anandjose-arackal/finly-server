class ReviewalLevelsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def create
    @result = ReviewalLevels::Create.(current_user, params)
    respond
  end

  def index
    @result = ReviewalLevels::Index.(current_user, params)
    respond
  end

  def update
    @result = ReviewalLevels::Update.(current_user, params)
    respond
  end

  def destroy
    @result = ReviewalLevels::Destroy.(current_user, params)
    respond
  end
end