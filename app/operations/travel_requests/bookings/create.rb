class TravelRequests::Bookings::Create < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :booking_request, :booking, :booking_parameters, :booking_attachments, :destination

  def authorized_user_types
    [:travel_manager]
  end

  def init
    self.booking_parameters = booking_params

    if params&.dig(:booking_request_id).present?
      booking_request_presenter = TravelRequests::BookingRequests::Show.(user, params)
      unless booking_request_presenter.success?
        add_message :error, booking_request_presenter.messages[:error]
        return
      end
      self.booking_request = booking_request_presenter.booking_request
      self.destination = booking_request_presenter.destination
    else
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
    end
  end

  def validate
    # Nothing to validate
  end

  def pre_process
    # Extracting booking attachments from params
    self.booking_attachments = user.company.booking_attachments.with_id(booking_parameters[:booking_attachments])

    # Remove :invoice_attachments from parameters
    self.booking_parameters.delete(:booking_attachments)
  end

  def process
    self.booking = booking_request.bookings.build(booking_parameters)
    self.booking.created_by_user = user
    if self.booking.valid?
      self.booking.save
      add_message :success, 'Successfully Added Booking'

      booking_attachments.update_all(booking_id: self.booking.id)
    else
      add_message :error, self.booking.errors.full_messages
    end
  end

end