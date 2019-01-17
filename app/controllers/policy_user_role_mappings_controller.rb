class PolicyUserRoleMappingsController < ApplicationController
  before_action -> { finly_authorize! :web}

  def index
    @result = PolicyUserRoleMappings::Index.(current_user, params)
    respond
  end

  def create
    @result = PolicyUserRoleMappings::Create.(current_user, params)
    respond
  end

  def update
    @result = PolicyUserRoleMappings::Update.(current_user, params)
    respond
  end

  def destroy
    @result = PolicyUserRoleMappings::Destroy.(current_user, params)
    respond
  end
end