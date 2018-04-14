class TravelRequests::Bookings::Update < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :booking_request, :booking, :booking_parameters,
                :booking_attachments, :booking_old_attachments

  def init
    self.booking_parameters = booking_params

    self.travel_request = TravelRequest.find_by(id: params[:travel_request_id]) # todo scope to company
    self.booking_request = ::BookingRequest.find_by(id: params[:booking_request_id])

    unless booking_request.present?
      add_message :error, 'Booking Request not found'
      return
    end
    self.booking = booking_request.bookings.find_by(booking_parameters[:id])

  end

  def validate
    if travel_request.blank?
      add_message :error, 'Travel Request not found'
    end

    unless booking.present?
      add_message :error, 'Booking not found'
    end
  end

  def pre_process
    # Extracting booking attachments from params
    self.booking_attachments = user.company.booking_attachments.with_id(booking_parameters[:booking_attachments])

    self.booking_old_attachments = booking.attachments

    # Remove :invoice_attachments from parameters
    self.booking_parameters.delete(:booking_attachments)

  end

  def process
    self.booking.assign_attributes(booking_parameters)
    self.booking.created_by_user = user
    if self.booking.valid?
      self.booking.save
      add_message :success, 'Successfully Updated Booking'

      booking_old_attachments.update_all(booking_id: nil)
      booking_attachments.update_all(booking_id: self.booking.id)
    else
      add_message :error, self.booking.errors.full_messages
    end
  end
end