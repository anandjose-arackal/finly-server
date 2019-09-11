class EventWorkflowsController < BaseControllers::WebBase

  def create
    endpoint EventManager::Workflows::Create, args: [params.permit!.to_h, {"current_user" => current_user}] do |m|
      # m.success {|result| render json: {success: true}}
    end
  end

  def show
    endpoint EventManager::Workflows::Show, args: [params.permit!.to_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: EventManager::Workflows::Representers::Show.new(result['model']).as_json, status: 200}
    end
  end

end