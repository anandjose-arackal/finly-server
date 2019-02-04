class Procure::ProcurementsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def index
    puts 'params from Procurements', params.inspect
    puts "was it performed?", performed?

    @result = Procurements::Index.(current_user, params)
    respond
  end

  def grn_pending
    # {"view"=>"admin", "menu"=>{"main"=>"procurements"}, "page"=>"1", "per_page"=>"30", "filter_procurement_type"=>"purchase_order", "filter_status_tags"=>["7"], "filter_po_status"=>" ", "filter_submission_date"=>"", "filter_creation_date_from"=>"", "filter_creation_date_to"=>""}
    params[:filter_status_tags] = ["7"]
    params[:view] = "admin"
    params[:menu] = {"main"=>"procurements"}
    params[:page] = "1"
    params[:per_page] = "30"
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = ["7"]
    params[:filter_po_status] = ""
    params[:filter_submission_date] = ""
    params[:filter_creation_date_from] = "" 
    params[:filter_creation_date_to] = "" 
    puts "params from grn pending", params.inspect
    # redirect_to procure_procurements_path(params: params)
    @result = Procurements::Index.(current_user, params)
    # render file: Rails.root.join('app/views/procure/procurements/index.json')

    if @result.success?
      respond_to do |format|
        format.json {
          render 'index'
        }
      end
    end

  end

  def grn_received
    # {"view"=>"admin", "menu"=>{"main"=>"procurements"}, "page"=>"1", "per_page"=>"30", "filter_procurement_type"=>"purchase_order", "filter_status_tags"=>["7"], "filter_po_status"=>" ", "filter_submission_date"=>"", "filter_creation_date_from"=>"", "filter_creation_date_to"=>""}
    params[:filter_status_tags] = ["8"]
    params[:view] = "admin"
    params[:menu] = {"main"=>"procurements"}
    params[:page] = "1"
    params[:per_page] = "30"
    params[:filter_procurement_type] = "purchase_order"
    params[:filter_status_tags] = ["8"]
    params[:filter_po_status] = ""
    params[:filter_submission_date] = ""
    params[:filter_creation_date_from] = "" 
    params[:filter_creation_date_to] = "" 
    puts "params from grn pending", params.inspect
    # redirect_to procure_procurements_path(params: params)
    @result = Procurements::Index.(current_user, params)
    render file: Rails.root.join('app/views/procure/procurements/index.json')

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
end