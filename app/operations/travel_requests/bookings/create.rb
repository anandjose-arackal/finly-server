class TravelRequests::Bookings::Create < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :booking_request, :booking, :booking_parameters, :booking_attachments

  def init
    self.booking_parameters = booking_params

    self.travel_request = TravelRequest.find(params[:travel_request_id]) # todo scope to company
    self.booking_request = ::BookingRequest.find(params[:booking_request_id])

  end

  def validate
    if travel_request.blank?
      add_message :error, 'Travel Request not found'
    end
    if booking_request.blank?
      add_message :error, 'Booking Request not found'
    end
  end

  def pre_process
    # Extracting booking attachments from params
    self.booking_attachments = user.company.booking_attachments.with_id(booking_parameters[:booking_attachments])

    # Remove :invoice_attachments from parameters
    self.booking_parameters.delete(:booking_attachments)

  end

  def process
    self.booking = booking_request.bookings.build(booking_parameters)
    if self.booking.valid?
      self.booking.save
      add_message :success, 'Successfully Added Booking'

      booking_attachments.update_all(booking_id: self.booking.id)
    else
      add_message :error, self.booking.errors.full_messages
    end
  end



end