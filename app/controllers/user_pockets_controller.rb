class UserPocketsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def assignable_pockets
    @result = UserPockets::AssignablePockets.(current_user, params)
    respond
  end

  def assign_pocket
    @result = UserPockets::AssignPocket.(current_user, params)
    respond_success_failure
  end
end