class UserPocketsController < BaseControllers::WebBase


  def assignable_pockets
    @result = UserPockets::AssignablePockets.(current_user, params)
    respond
  end

  def assign_pocket
    @result = UserPockets::AssignPocket.(current_user, params)
    respond_success_failure
  end

  def index
    @result = UserPockets::Index.(current_user, params)
    respond
  end
end
