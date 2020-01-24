class TaskWorkflowsController < BaseControllers::WebBase

  def create
    endpoint TaskManager::Workflows::Create,
             args: [params.to_unsafe_h, {"current_user" => current_user}]
  end

  def show
    endpoint TaskManager::Workflows::Show,
             args: [params.to_unsafe_h, {"current_user" => current_user}],
             representer: {class: TaskManager::Workflows::Representers::Show, data_key: 'model'}

    # endpoint TaskManager::Workflows::Show,
    #          representer: {class: TaskManager::Workflows::Representers::Show, data_key: 'model'},
    #          args: [params.permit!.to_h, {"current_user" => current_user}] do |m|
    # m.success {|result| render json: TaskManager::Workflows::Representers::Show.new(result['model']).as_json, status: 200}
    # end
  end

  def index
    endpoint TaskManager::Workflows::Index,
             args: [params.to_unsafe_h, {"current_user" => current_user}],
             representer: {class: TaskManager::Workflows::Representers::Index, data_key: 'model.index'}
  end

  def documents
    endpoint TaskManager::Documents::Index,
             args: [params.to_unsafe_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: result['documents'], status: 200}
    end
  end

  def configuration
    endpoint TaskManager::Documents::Configuration,
             args: [params.to_unsafe_h, {"current_user" => current_user}] do |m|
      m.success {|result| render json: result['config'], status: 200}
    end
  end

end