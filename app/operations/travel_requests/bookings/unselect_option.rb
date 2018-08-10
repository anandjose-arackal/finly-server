class TravelRequests::Bookings::UnselectOption < TravelRequests::Bookings::Base
  attr_accessor :booking, :destination, :travel_request

  def init
    show_presenter = TravelRequests::Bookings::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.booking = show_presenter.booking
    self.destination = show_presenter.destination
    self.travel_request = show_presenter.travel_request
  end

  def validate
    # todo validate if booking is an option and can be selected. That's booking for the request is not confirmed
  end

  def process

  end

end