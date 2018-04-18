class TravelRequests::Bookings::Destroy < TravelRequests::Bookings::Base
  attr_accessor :booking

  def init
    # self.booking_parameters = booking_params

    # self.travel_request = TravelRequest.find_by(id: params[:travel_request_id]) # todo scope to company
    booking_id = params[:id] || params[:booking_id]
    
    self.booking = ::Booking.find_by(id: booking_id)

  end

  def validate
    unless booking.present?
      add_message :error, 'Booking not found'
    end
  end

  def pre_process

  end

  def process
    unless self.booking.destroy
      add_message :error, self.booking.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Deleted Booking'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end