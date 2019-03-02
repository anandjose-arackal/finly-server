class Policy::ApprovalWorkflows::LevelUserReviewers::Base < BaseOperation
  attr_accessor :level_user_reviewer_params

  def authorized_user_types
    [:admin]
  end

  def init
    self.level_user_reviewer_params = generate_params
  end

  private

  def generate_params
    params.require(:level_user_reviewer).permit(:id, :user_id, :reviewer_id, :level_id, :threshold, :exception)
  end

end