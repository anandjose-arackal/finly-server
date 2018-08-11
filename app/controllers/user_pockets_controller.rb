class UserPocketsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def assignable_pockets
    @result = UserPockets::AssignablePockets.(current_user, params)
    respond
  end
end