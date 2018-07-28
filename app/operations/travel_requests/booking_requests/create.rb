class TravelRequests::BookingRequests::Create < TravelRequests::BookingRequests::Base
  attr_accessor :destination, :booking_request, :travel_request

  def pre_validate
    user_present? and params_present?
  end

  def init
    destination_presenter = TravelRequests::Destinations::Show.(user, {
        travel_request_id: params[:travel_request_id],
        id: params[:destination_id],
        view: params[:view]
    })
    unless destination_presenter.success?
      add_message :error, destination_presenter.messages[:error]
      return
    end
    self.destination = destination_presenter.destination
    self.travel_request = destination_presenter.travel_request

    self.booking_request = self.destination.booking_requests.build strong_params
    self.booking_request.destination = self.destination
    self.booking_request.travel_request = self.travel_request
  end

  def validate
    unless self.booking_request.valid?
      add_message :error, self.booking_request.errors.full_messages
    end
  end

  def process
    unless self.booking_request.save
      add_message :error, self.booking_request.errors.full_messages
    end
  end

end