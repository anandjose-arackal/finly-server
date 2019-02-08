class Procure::ProcurementsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def index
    @result = Procurements::Index.(current_user, params)
    respond
  end

  def documents
    @result = Procurements::Documents.(current_user, params)
    respond
  end

  def count
    @result = Procurements::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def show
    @result = Procurements::Show.(current_user, params)
    respond
  end

  def create
    @result = Procurements::Create.(current_user, params)
    respond
  end

  def filter_config
    @result = Procurements::FilterConfig.(current_user, params)
    respond
  end

  def actions_configuration
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end
end