class PolicyUserRolesController < ApplicationController
  before_action -> { finly_authorize! :web}

  def index
    @result = PolicyUserRoles::Index.(current_user, params)
    respond
  end

  def create
    @result = PolicyUserRoles::Create.(current_user, params)
    respond
  end

  def update
    @result = PolicyUserRoles::Update.(current_user, params)
    respond
  end

  def destroy
    @result = PolicyUserRoles::Destroy.(current_user, params)
    respond
  end
end