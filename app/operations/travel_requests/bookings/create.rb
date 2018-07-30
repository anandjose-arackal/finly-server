class TravelRequests::Bookings::Create < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :booking, :parent_booking, :booking_parameters, :booking_attachments, :destination, :travel_request

  def authorized_user_types
    [:employee, :travel_manager]
  end

  def init
    params[:booking][:booking_status_id] = BookingStatus.id_for(params[:status])
    self.booking_parameters = booking_params

    if params&.dig(:parent_booking_id).present?
      parent_booking_presenter = TravelRequests::Bookings::Show.(user, {
          id: params&.dig(:parent_booking_id),
          travel_request_id: params[:travel_request_id],
          destination_id: params[:destination_id],
          view: params&.dig(:view)
      })
      unless parent_booking_presenter.success?
        add_message :error, parent_booking_presenter.messages[:error]
        return
      end
      self.parent_booking = parent_booking_presenter.booking
      self.destination = parent_booking_presenter.destination
      self.travel_request = parent_booking_presenter.travel_request
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
      self.travel_request = destination_presenter.travel_request
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
    self.booking = self.destination.bookings.build(booking_parameters)
    self.booking.parent_booking = self.parent_booking
    self.booking.travel_request = self.travel_request
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