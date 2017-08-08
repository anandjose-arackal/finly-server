class UserGroupItemsController < ApplicationController


  before_action -> { finly_authorize! :web}

  def create
    @result = UserGroup::Item::Users::Add.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def show
    @result = UserGroup::Item::Show.(current_user, params)
    respond
  end

  def update
    @result = UserGroup::Item::Update.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
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
