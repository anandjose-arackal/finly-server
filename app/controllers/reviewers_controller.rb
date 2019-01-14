class ReviewersController < BaseControllers::WebBase

  def create
    @result = ReviewalLevels::Reviewers::Create.(current_user, params)
    respond
  end
end
