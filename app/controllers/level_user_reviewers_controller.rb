class LevelUserReviewersController < ApplicationController
  before_action -> { finly_authorize! :web }


  # Create LURM (Override for reviewer in levels)
  def create
    @result = ReviewalLevels::LevelUserReviewers::Create.(current_user, params)
  end

  # Update LURM
  def update
    @result = ReviewalLevels::LevelUserReviewers::Update.(current_user, params)
  end

  # Destroy LURM
  def destroy
    @result = ReviewalLevels::LevelUserReviewers::Destroy.(current_user, params)
  end
end