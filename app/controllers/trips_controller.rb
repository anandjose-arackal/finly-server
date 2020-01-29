class TripsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint Docs::Trips::Ops::Create
  end

  def index
    endpoint Docs::Trips::Ops::Index
  end

  def show
    endpoint Docs::Trips::Ops::Show
  end

end
