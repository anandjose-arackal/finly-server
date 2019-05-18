class AdminUsers::CallCenter::UsersController < BaseControllers::AdminBase


  def search
    @result = Admin::CallCenter::Search.(current_user, params)
    respond
  end

end
