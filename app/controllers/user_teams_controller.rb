class UserTeamsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    @result = UserTeam::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = UserTeam::Index.(current_user, params)
    respond
  end

  def update
    # @result = UserGroup::Update.(current_user, params)
    # respond response: (@result&.success? ? :success : :failure)
  end

  def show
    # @result = UserGroup::Destroy.(current_user, params)
    # respond response: (@result&.success? ? :success : :failure)
  end

  def destroy
    # @result = UserGroup::Destroy.(current_user, params)
    # respond response: (@result&.success? ? :success : :failure)
  end

end
