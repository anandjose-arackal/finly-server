class TravelRequests::Bookings::SelectOption < TravelRequests::Bookings::Base
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
  end

  def process
    # In-case any booking is already selected, set the selected booking as an option
    self.booking.parent_booking.bookings.selected_for_booking.first&.update(booking_status_id: BookingStatus.id_for(:option))

    self.booking.update(booking_status_id: BookingStatus.id_for(:selected_for_booking))
  end

end