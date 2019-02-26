class ReviewalLevelsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def create
    @result = ReviewalLevels::Create.(current_user, params)
    respond
  end

  def index
    @result = ReviewalLevels::Index.(current_user, params)
    respond
  end

  # Ideally rest of the operations should be present under Policy namespace
  def index_user_level
    @result = Policy::ReviewalLevels::IndexUserLevel.(current_user, params)
    respond
  end

  def show_user_level
    @result = Policy::ReviewalLevels::ShowUserLevel.(current_user, params)
    respond
  end


  def update
    @result = ReviewalLevels::Update.(current_user, params)
    respond
  end

  def destroy
    @result = ReviewalLevels::Destroy.(current_user, params)
    respond
  end

end