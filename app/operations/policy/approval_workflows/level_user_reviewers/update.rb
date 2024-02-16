class Policy::ApprovalWorkflows::LevelUserReviewers::Update < Policy::ApprovalWorkflows::LevelUserReviewers::Base
  attr_accessor :lurm, :reviewer

  def init
    super

    id = params[:id] || params[:level_user_reviewer_id] || params[:level_user_reviewer_mapping_id]
    self.lurm = Policy::ApprovalWorkflows::LevelUserReviewers::Index.(user, params).lurms.with_id(id).first rescue nil

    if level_user_reviewer_params[:min].blank?
      level_user_reviewer_params[:min] = 0
    elsif level_user_reviewer_params[:min].to_f < 0
      add_message :error, "Min cannot be less than 0"
    end
  end

  def authorized_user_types
    [:admin,:vendor_payments_admin]
  end

  def validate
    unless self.lurm.present?
      add_message :error, "Record not found "
    end

    if level_user_reviewer_params[:max].present? && level_user_reviewer_params[:max].to_f <= level_user_reviewer_params[:min].to_f
      add_message :error, "Max cannot be less than or equal to min"
    end
  end
  def pre_process
    dup_check_params = level_user_reviewer_params
    dup_check_params[:max] = nil if dup_check_params[:max].blank?
    if Policy::ApprovalWorkflows::LevelUserReviewers::Index.(user, params).lurms.where(deleted_at: nil).where(level_user_reviewer_params).exists?
      add_message :error, "User already exists in level (#{lurm.level&.name})"
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