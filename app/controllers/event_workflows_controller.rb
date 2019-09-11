class EventWorkflowsController < BaseControllers::WebBase

  def create
    @result = EventManager::Workflows::Show.(params, "current_user" => current_user)
    respond_success_failure
  end

  def show
    @result = EventManager::Workflows::Show.(params, "current_user" => current_user)
    respond
  end

end