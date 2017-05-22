class UserGroupItemsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def show
    @result = UserGroup::Item::Show.(current_user, params)
    respond
  end

end
