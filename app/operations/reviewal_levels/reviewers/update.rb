class ReviewalLevels::Reviewers::Update < ReviewalLevels::Reviewers::Base
  # Although the name suggest it creats reviewers, it actually creates the mapping betweeen
  # reviewer and level
  attr_accessor :reviewer_params, :reviewer, :reviewal_level, :level_reviewer_mapping, :reviewer_params

  def init
    reviewal_levels = ReviewalLevels::Index.(user, params).reviewal_levels

    id = params[:reviewal_level_id]
    self.reviewal_level = reviewal_levels.find_by id: id

    id = params[:id]
    self.level_reviewer_mapping = reviewal_level&.level_reviewer_mappings.find_by id: id

    self.reviewer_params = reviewer_parameters

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
    end

    unless level_reviewer_mapping.present?
      add_message :error, 'Reviewer not found'
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
    unless self.level_reviewer_mapping.update(reviewer_params)
      add_message :error, level_reviewer_mapping.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully Updated Reviewer'
  end

  private

  def reviewer_parameters
    params.require(:level_reviewer_mapping).permit(:threshold, :exception, :wo_exception, :min, :max)
  end

end
