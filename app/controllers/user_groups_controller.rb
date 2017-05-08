class UserGroupsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    @result = UserGroup::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = UserGroup::Index.(current_user, params)
    respond
  end

  def update
    @result = UserGroup::Update.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def create_item
    @result = UserGroup::Items::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def update_item
    @result = UserGroup::Items::Update.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  # def destroy_item
  #
  # end

  # def destroy
  #   @result = UserGroup::Destroy.(current_user, params)
  #   respond response: (@result&.success? ? :success : :failure)
  # end

end
