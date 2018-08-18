class TravelRequests::Bookings::Destroy < TravelRequests::Bookings::Base
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
    if self.booking.bookings.confirmed.present?
      add_message :error, 'Please mark the ticket as cancelled before deleting booking request'
      return
    end
  end

  def process
    unless self.booking.destroy
      add_message :error, self.booking.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Removed the booking'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end