class ReviewalLevels::Reviewers::Update < ReviewalLevels::Reviewers::Base
  # Although the name suggest it creats reviewers, it actually creates the mapping betweeen
  # reviewer and level
  attr_accessor :reviewer_params, :reviewer, :reviewal_level, :level_reviewer_mapping

  def init
    reviewal_levels = ReviewalLevels::Index.(user, params).reviewal_levels

    id = params[:reviewal_level_id]
    self.reviewal_level = reviewal_levels.find_by id: id

    id = params[:id]
    self.level_reviewer_mapping = reviewal_level.level_reviewer_mappings.find_by id: id
  end

  def validate
    unless reviewal_level.present?
      add_message :error, 'Level not found'
    end
  end

  def process
    level_reviewer_mapping = reviewal_level.level_reviewer_mappings.new(reviewer_params)

    if level_reviewer_mapping.valid?
      level_reviewer_mapping.save
    end
  end

  def post_process
    add_message :success, 'Successfully Added Reviewer'
  end

  private

  def reviewer_parameters
    params.require(:level_reviewer_mapping).permit(:level_id, :threshold, :exception)
  end

end
