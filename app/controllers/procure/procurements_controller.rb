class Procure::ProcurementsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def index
    puts 'params from Procurements', params.inspect
    puts "was it performed?", performed?

    @result = Procurements::Index.(current_user, params)
    respond
  end

  def grn_pending
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = ["7"]
    @result = Procurements::Index.(current_user, params)

    if @result.success?
      respond_to do |format|
        format.json {
          render 'index'
        }
      end
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while finding details. Please check the parameters sent.'
    end

  end

  def grn_received
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = ["8"]

    @result = Procurements::Index.(current_user, params)

    if @result.success?
      respond_to do |format|
        format.json {
          render 'index'
        }
      end
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while finding details. Please check the parameters sent.'
    end

  end

  def documents
    @result = Procurements::Documents.(current_user, params)
    respond
  end

  def count
    @result = Procurements::Count.(current_user, params)
    render json: { count: @result.count.as_json, status_count: @result.status_count.as_json }
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