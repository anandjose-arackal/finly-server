class Bbps::ComplaintsController < BaseControllers::WebBase
  layout 'trailblazers'
  def index
    endpoint Docs::UtilityBills::Complaints::Ops::Index
  end

  def create
    endpoint Docs::UtilityBills::Complaints::Ops::Raise
  end

  def show
    params[:complaint_id] = params[:id] || params[:complaint_id]
    endpoint Docs::UtilityBills::Complaints::Ops::Status
  end
end