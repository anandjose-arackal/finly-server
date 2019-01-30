class TravelRequests::Bookings::Show < TravelRequests::Bookings::Base
  attr_accessor :booking, :destination, :travel_request

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:travel_request_id).blank?
      add_message :error, 'Travel Request not found'
      return
    end
    if params&.dig(:destination_id).blank?
      add_message :error, 'Destination not found'
      return
    end
    if params&.dig(:booking_id).blank? and params&.dig(:id).blank?
      add_message :error, 'Booking not found'
      return
    end
  end

  def init
    # if params&.dig(:booking_request_id).present?
    #   booking_request_presenter = TravelRequests::BookingRequests::Show.(user, params)
    #   unless booking_request_presenter.success?
    #     add_message :error, booking_request_presenter.messages[:error]
    #     return
    #   end
    #   self.booking_request = booking_request_presenter.booking_request
    #   self.destination = booking_request_presenter.destination
    #   self.travel_request = booking_request_presenter.travel_request
    # else
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
    # end
    id = (params[:booking_id] or params[:id])
    self.booking = self.destination.bookings.with_id(id)&.first
  end

  def validate
    unless self.booking.present?
      add_message :error, 'Booking not found'
      return
    end
  end

  def success
    params[:booking] = self.booking
    params[:destination] = self.destination
    params[:travel_request] = self.travel_request
    TravelRequests::Bookings::Show::SuccessPresenter.new(user, params, messages)
  end

  class TravelRequests::Bookings::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :booking, :destination, :travel_request

    def init
      self.booking = params[:booking]
      self.destination = params[:destination]
      self.travel_request = params[:travel_request]
    end

  end

end