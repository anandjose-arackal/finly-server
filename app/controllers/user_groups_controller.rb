class UserGroupsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    @result = UserGroup::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
