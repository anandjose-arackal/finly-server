class PolicyUserRolesController < BaseControllers::WebBase

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

  def vp_role_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end
end