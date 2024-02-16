class ReviewalLevels::Reviewers::Destroy < ReviewalLevels::Reviewers::Base
  # Although the name suggest it creats reviewers, it actually creates the mapping betweeen
  # reviewer and level
  attr_accessor :reviewer_params, :reviewer, :reviewal_level, :level_reviewer_mapping

  def init
    id = params[:reviewal_level_id]
    reviewal_levels = ReviewalLevels::Index.(user, params).reviewal_levels
    self.reviewal_level = reviewal_levels.find_by id: id

    id = params[:id] || params[:level_reviewer_mapping_id]
    self.level_reviewer_mapping = reviewal_level.level_reviewer_mappings.find_by id: id
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
  end

  def process
    unless self.level_reviewer_mapping.destroy
      add_message :error, level_reviewer_mapping.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully Removed Reviewer'
  end
end
