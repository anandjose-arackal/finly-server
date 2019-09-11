class EventWorkflowsController < BaseControllers::WebBase

  def create
    endpoint EventManager::Workflows::Create,
             args: [params.to_unsafe_h, {"current_user" => current_user}]
  end

  def show
    endpoint EventManager::Workflows::Show,
             representer: {class: EventManager::Workflows::Representers::Show, data_key: 'model'},
             args: [params.to_unsafe_h, {"current_user" => current_user}]

    # endpoint EventManager::Workflows::Show,
    #          representer: {class: EventManager::Workflows::Representers::Show, data_key: 'model'},
    #          args: [params.permit!.to_h, {"current_user" => current_user}] do |m|
    # m.success {|result| render json: EventManager::Workflows::Representers::Show.new(result['model']).as_json, status: 200}
    # end
  end

  def index
    endpoint EventManager::Workflows::Index,
             representer: {class: EventManager::Workflows::Representers::Index, data_key: 'model.index'},
             args: [params.to_unsafe_h, {"current_user" => current_user}]
  end

  def documents
    endpoint EventManager::Documents::Index,
             # representer: {name: 'render', data_key: 'filters'},
             args: [params.to_unsafe_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: result['documents'], status: 200}
    end
  end

  def configuration
    endpoint EventManager::Documents::Configuration,
             args: [params.to_unsafe_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: result['config'], status: 200}
    end
  end

end