class ReviewalLevels::Reviewers::Create < ReviewalLevels::Reviewers::Base
  # Although the name suggest it creats reviewers, it actually creates the mapping betweeen
  # reviewer and level
  attr_accessor :reviewer_params, :reviewer, :reviewal_level, :level_reviewer_mapping

  def init
    self.reviewer_params = reviewer_parameters
    reviewal_levels = ReviewalLevels::Index.(user, params).reviewal_levels
    self.reviewal_level = reviewal_levels.find_by id: params[:reviewal_level_id]

    # self.reviewer = User.find_by id: reviewer_params[:reviewer_id]
    self.reviewer = user.company.users.find_by id: reviewer_params[:reviewer_id]

    if reviewer_params[:min].blank?
      reviewer_params[:min] = 0
    elsif reviewer_params[:min].to_f < 0
      add_message :error, "Min cannot be less than 0"
    end
  end

  def authorized_user_types
    [:admin,:vendor_payments_admin]
  end

  def validate
    unless reviewal_level.present?
      add_message :error, 'Level not found'
      return
    end

    unless reviewal_level.policy.company == user.company
      add_messsage :error, 'Invalid configuration provided'
    end

    unless reviewer.present?
      add_message :error, 'Reviewer not found'
    end

    unless reviewer.present?
      add_message :error, 'Unknown Reviewer'
    end

    if reviewer_params[:max].present? && reviewer_params[:max].to_f <= reviewer_params[:min].to_f
      add_message :error, "Max cannot be less than or equal to min"
    end
  end

  def pre_process
    dup_check_params = reviewer_params
    dup_check_params[:max] = nil if dup_check_params[:max].blank?
    if reviewal_level.level_reviewer_mappings.non_deleted.where(dup_check_params).exists?
      add_message :error, "User already exists in level (#{reviewal_level&.name})"
    end
  end

  def process
    level_reviewer_mapping = reviewal_level.level_reviewer_mappings.new(reviewer_params)

    if level_reviewer_mapping.valid?
      if level_reviewer_mapping.save
        # Map reviewer to the policy user role
        reviewal_level.set_reviewer_role_in_policy(reviewer)
      end
    end
  end

  def post_process
    add_message :success, 'Successfully Added Reviewer'
  end

end
