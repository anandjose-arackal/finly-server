class TravelRequests::Bookings::Cancel < TravelRequests::Bookings::Base
  attr_accessor :booking

  def init
    booking_presenter = TravelRequests::Bookings::Show.(user, params)
    unless booking_presenter.success?
      add_message :error, booking_presenter.messages[:error]
      return
    end
    self.booking = booking_presenter.booking
  end

  def validate
    unless self.booking.confirmed?
      add_message :error, 'You can only cancel confirmed bookings'
      return
    end
  end

  def process
    unless self.booking.update(booking_status_id: BookingStatus.id_for(:cancelled))
      self.booking.parent_booking.update(booking_status_id: BookingStatus.id_for(:cancelled))
      add_message :error, self.booking.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Booking cancelled'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end