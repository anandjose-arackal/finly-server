class AdminUsers::CallCenter::UsersController < ApplicationController

  before_action -> { doorkeeper_authorize! :admin}

  def search
    @result = Admin::CallCenter::Search.(current_user, params)
    respond
  end

end