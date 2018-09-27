class TravelRequests::Review::RejectBookingRequest < TravelRequests::Bookings::Base
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
    # todo clear existing options selections if selected
  end

  def validate
    # todo validate if booking is an option and can be selected
    if booking.rejected?
      add_message :error, 'The selected request has already been rejected'
      return
    end
    unless booking.request?
      add_message :error, 'You cannot reject this request'
      return
    end
  end

  def process
    self.booking.update(booking_status_id: BookingStatus.id_for(:rejected))
  end

end