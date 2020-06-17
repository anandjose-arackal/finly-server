class ActionsController < BaseControllers::WebBase

  def show
    @op = ActionManager::Router.dispatch(params[:route], params: params.to_unsafe_h, current_user: current_user)
    respond response: :failure, message: "Invalid Request" unless  @op.success?
  end

  def validate
    endpoint ActionManager::Validate
  end

end
