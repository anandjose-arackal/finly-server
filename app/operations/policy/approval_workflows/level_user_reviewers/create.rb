class Policy::ApprovalWorkflows::LevelUserReviewers::Create < Policy::ApprovalWorkflows::LevelUserReviewers::Base
  attr_accessor :level_user_reviewer, :level, :target_user, :reviewer

  def init
    super
 
    policy_ids = user.company.policies.non_deleted.pluck(:id)
    self.level = ReviewalLevel.with_policy_id(policy_ids).non_deleted.with_id(level_user_reviewer_params[:level_id]).first rescue nil
    self.target_user = user.company.users.find_by id: level_user_reviewer_params[:user_id]
    self.reviewer = user.company.users.find_by id: level_user_reviewer_params[:reviewer_id]

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
    unless self.level.present?
      add_message :error, "Invalid Level Details"
    end

    unless self.target_user.present?
      add_message :error, "Invalid User Details"
    end

    if level_user_reviewer_params[:reviewer_id].present? && self.reviewer.blank?
      add_message :error, "Invalid Reviewer Details"
    end

    if level_user_reviewer_params[:max].present? && level_user_reviewer_params[:max].to_f <= level_user_reviewer_params[:min].to_f
      add_message :error, "Max cannot be less than or equal to min"
    end
  end

  def pre_process
    dup_check_params = level_user_reviewer_params
    dup_check_params[:max] = nil if dup_check_params[:max].blank?
    if LevelUserReviewerMapping.where(deleted_at: nil).where(level_user_reviewer_params).exists?
      add_message :error, "User already exists in level (#{self.level&.name})"
    end
  end

  def process
    lurm = LevelUserReviewerMapping.new level_user_reviewer_params

    lurm.policy_id = self.level.policy_id

    unless lurm.save
      add_message :error, lurm.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Added Override"
  end
end