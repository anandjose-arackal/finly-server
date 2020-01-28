class TripsController < BaseControllers::WebBase
  layout :resolve_layout

  def create
    endpoint Docs::Trips::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def index
    endpoint Docs::Trips::Ops::Index
  end

  def show

  end

end
