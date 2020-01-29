class TripsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint Docs::Trips::Ops::Create
  end

  def index
    endpoint Docs::Trips::Ops::Index
  end

  def update
    endpoint Docs::Trips::Ops::Update
  end

  def show
    endpoint Docs::Trips::Ops::Show
  end

  def show_header
    endpoint Docs::Trips::Ops::Show
  end

  def show_passengers
    endpoint Docs::Trips::Ops::Show
  end

  def show_routes
    endpoint Docs::Trips::Ops::Show
  end

  def show_booking_requests
    endpoint Docs::Trips::Ops::Show
  end

end
