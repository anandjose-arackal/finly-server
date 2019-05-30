class LevelUserReviewersController < BaseControllers::WebBase

  # Create LURM (Override for reviewer in levels)
  def create
    @result = Policy::ApprovalWorkflows::LevelUserReviewers::Create.(current_user, params)
    respond
  end

  # Update LURM
  def update
    @result = Policy::ApprovalWorkflows::LevelUserReviewers::Update.(current_user, params)
    respond
  end

  # Destroy LURM
  def destroy
    @result = Policy::ApprovalWorkflows::LevelUserReviewers::Destroy.(current_user, params)
    respond
  end
end