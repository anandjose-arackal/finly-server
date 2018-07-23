class TravelRequests::BookingRequests::Show < TravelRequests::BookingRequests::Base
  attr_accessor :destination, :booking_request

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

    id = (params[:booking_request_id] || params[:id])
    self.booking_request = self.destination.booking_requests.with_id(id)&.first
  end

  def validate
    if self.booking_request.blank?
      add_message :error, 'Booking request not found'
    end
  end

  def success
    TravelRequests::BookingRequests::Show::SuccessPresenter.new(user, {destination: self.destination, booking_request: self.booking_request}, messages)
  end

  class TravelRequests::BookingRequests::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :destination, :booking_request

    def init
      self.destination = params[:init]
      self.booking_request = params[:booking_request]
    end

  end

end