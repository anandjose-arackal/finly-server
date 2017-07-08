class UserTeamsController < ApplicationController


  before_action :doorkeeper_authorize!

  def create
    @result = UserTeam::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = UserTeam::Index.(current_user, params)
    respond
  end

  def update
    @result = UserTeam::Update.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def show
    @result = UserTeam::Show.(current_user, params)
    respond
  end

  def destroy
    @result = UserTeam::Destroy.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def set_restrictions
    @result = UserTeam::BatchUpdate::Restriction.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
