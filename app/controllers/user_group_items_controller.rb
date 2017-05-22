class UserGroupItemsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    @result = UserGroup::Item::Users::Add.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def show
    @result = UserGroup::Item::Show.(current_user, params)
    respond
  end

  def pending_users
    @result = UserGroup::Item::Users::AddableUsers.(current_user, params)
    respond
  end

  def destroy
    @result = UserGroup::Item::Users::Remove.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
