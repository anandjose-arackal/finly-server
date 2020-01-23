class TripsController < BaseControllers::WebBase

  def index
    endpoint Docs::Trips::Ops::Index
  end

  def show

  end

end
