class Policy::ApprovalWorkflows::LevelUserReviewers::Update < Policy::ApprovalWorkflows::LevelUserReviewers::Base
  attr_accessor :lurm, :reviewer

  def init
    super

    id = params[:id] || params[:level_user_reviewer_id] || params[:level_user_reviewer_mapping_id]
    self.lurm = Policy::ApprovalWorkflows::LevelUserReviewers::Index.(user, params).lurms.with_id(id).first rescue nil
  end

  def validate
    unless self.lurm.present?
      add_message :error, "Record not found "
    end
  end

  def process
    unless self.lurm.update(level_user_reviewer_params)
      add_message :error, self.lurm.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Updated Override"
  end

  private

  # Only allow updation of threshold & exception
  def generate_params
    params.require(:level_user_reviewer).permit(:threshold, :exception)
  end
end