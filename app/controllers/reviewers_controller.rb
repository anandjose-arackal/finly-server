class ReviewersController < BaseControllers::WebBase

  # Adds reviewers to levels
  def create
    @result = ReviewalLevels::Reviewers::Create.(current_user, params)
    respond
  end

  # Updates reviewers in levels
  def update
    @result = ReviewalLevels::Reviewers::Update.(current_user, params)
    respond
  end

  # Destroys reviewers from levels
  def destroy
    @result = ReviewalLevels::Reviewers::Destroy.(current_user, params)
    respond
  end
end
