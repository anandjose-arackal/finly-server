class Policy::ApprovalWorkflows::LevelUserReviewers::Update < Policy::ApprovalWorkflows::LevelUserReviewers::Base
  attr_accessor :lurm, :reviewer

  def init
    super

    id = params[:id] || params[:level_user_reviewer_id] || params[:level_user_reviewer_mapping_id]
    self.lurm = Policy::ApprovalWorkflows::LevelUserReviewers::Index.(user, params).lurms.with_id(id).first rescue nil

    if level_user_reviewer_params[:min].blank?
      level_user_reviewer_params[:min] = 0
    end
  end

  def validate
    unless self.lurm.present?
      add_message :error, "Record not found "
    end

    if level_user_reviewer_params[:max].present? && level_user_reviewer_params[:max].to_f <= level_user_reviewer_params[:min].to_f
      add_message :error, "Max cannot be less than or equal to min"
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
    params.require(:level_user_reviewer).permit(:threshold, :exception, :wo_exception, :min, :max)
  end
end