class TravelRequests::Bookings::MarkAsUnavailable < TravelRequests::Bookings::Base

  attr_accessor :booking

  def authorized_user_types
    [:travel_manager]
  end

  def init
    booking_presenter = TravelRequests::Bookings::Show.(user, params)
    unless booking_presenter.success?
      add_message :error, booking_presenter.messages[:error]
      return
    end
    self.booking = booking_presenter.booking
  end

  def validate
    unless self.booking.selected_for_booking?
      add_message :error, 'Only selected options can be marked as unavailable'
      return
    end
  end

  def process
    self.booking.update(booking_status_id: BookingStatus.id_for(:unavailable))
  end

end