class Procure::ProcurementsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def index
    if params['filter_procurement_type'] == 'purchase_order'
      @result = Procurements::Index.(current_user,params)
    elsif params['filter_procurement_type'] == 'non_po_invoice'
      @result = Procurements::NonPoIndex.(current_user,params)
    end
    respond
  end

  def grn_pending
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment)]
    @result = Procurements::Grn::Pending::Index.(current_user, params)
    respond
    # if @result.success?
    #   respond_to do |format|
    #     format.json {
    #       render 'index'
    #     }
    #   end
    # else
    #   respond response: :failure, message: @result.messages[:error] || 'Error while finding details. Please check the parameters sent.'
    # end

  end

  def grn_received
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = [StatusTag.id_for(:shipment_received)]

    @result = Procurements::Grn::Received::Index.(current_user, params)
    respond
    # if @result.success?
    #   respond_to do |format|
    #     format.json {
    #       render 'index'
    #     }
    #   end
    # else
    #   respond response: :failure, message: @result.messages[:error] || 'Error while finding details. Please check the parameters sent.'
    # end

  end

  def documents
    @result = Procurements::Documents.(current_user, params)
    respond
  end

  def count
    # To make things working in short span
    if params[:document_type].present? && params[:document_type] == 'grn_count'
      @result = Procurements::Grn::Count.(current_user, params)
    else
      @result = Procurements::Count.(current_user, params)
    end
    if @result.success?
      render json: { count: @result.count.as_json, status_count: @result.status_count.as_json }
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while finding details.'
    end
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