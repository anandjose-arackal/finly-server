class EventWorkflowsController < BaseControllers::WebBase

  def create
    endpoint EventManager::Workflows::Create,
             args: [params.permit!.to_h, {"current_user" => current_user}] # do |m|
    # m.success {|result| render json: {success: true}}
    #end
  end

  def show
    endpoint EventManager::Workflows::Show,
             representer: {class: EventManager::Workflows::Representers::Show, data_key: 'model'},
             args: [params.permit!.to_h, {"current_user" => current_user}] #do |m|
    # m.success {|result| render json: EventManager::Workflows::Representers::Show.new(result['model']).as_json, status: 200}
    #end
  end

  def documents
    endpoint EventManager::Documents::Index,
             # representer: {name: 'render', data_key: 'filters'},
             args: [params.permit!.to_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: result['documents'], status: 200}
    end
  end

  def configuration
    endpoint EventManager::Documents::Configuration,
             args: [params.permit!.to_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: result['config'], status: 200}
    end
  end

end