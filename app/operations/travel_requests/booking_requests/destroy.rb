class TravelRequests::BookingRequests::Destroy < TravelRequests::BookingRequests::Base
  attr_accessor :destination, :booking_request

  def pre_validate
    user_present? and params_present?
  end

  def init
    requests_presenter = TravelRequests::BookingRequests::Show.(user, {
        travel_request_id: params[:travel_request_id],
        destination_id: params[:destination_id],
        id: params[:id],
        view: params[:view]
    })
    unless requests_presenter.success?
      add_message :error, requests_presenter.messages[:error]
      return
    end
    self.destination = requests_presenter.destination
    self.booking_request = requests_presenter.booking_request
  end

  def validate
    if self.booking_request.blank?
      add_message :error, 'Booking request not found'
      return
    end
  end

  def process
    unless self.booking_request.destroy
      add_message :error, self.booking_request.errors.full_messages
    end
  end

end