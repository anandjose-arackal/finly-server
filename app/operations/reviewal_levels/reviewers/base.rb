class ReviewalLevels::Reviewers::Base < BaseOperation
  private

  def reviewer_parameters
    params.require(:level_reviewer_mapping).permit(:level_id, :reviewer_id, :threshold, :exception, :wo_exception, :min, :max)
  end
end