class LevelUserReviewersController < ApplicationController
  before_action -> { finly_authorize! :web }


  # Create LURM (Override for reviewer in levels)
  def create
    @result = Policy::ReviewalLevels::LevelUserReviewers::Create.(current_user, params)
  end

  # Update LURM
  def update
    @result = Policy::ReviewalLevels::LevelUserReviewers::Update.(current_user, params)
  end

  # Destroy LURM
  def destroy
    @result = Policy::ReviewalLevels::LevelUserReviewers::Destroy.(current_user, params)
  end
end