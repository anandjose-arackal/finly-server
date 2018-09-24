class TravelRequests::Bookings::MarkAsUnavailable < TravelRequests::Bookings::Base
  attr_accessor :selected_for_booking

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
    self.selected_for_booking = self.booking.bookings.selected_for_booking
  end

  def validate
    if self.selected_for_booking.blank?
      add_message :error, 'Only selected options can be marked as unavailable'
    end
  end

  def process
    self.selected_for_booking.update_all(booking_status_id: BookingStatus.id_for(:unavailable))
  end

end