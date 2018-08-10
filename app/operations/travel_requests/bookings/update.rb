class TravelRequests::Bookings::Update < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :booking_request, :booking, :booking_parameters,
                :booking_attachments, :booking_old_attachments

  def init
    booking_presenter = TravelRequests::Bookings::Show.(user, params)
    unless booking_presenter.success?
      add_message :error, booking_presenter.messages[:error]
      return
    end
    self.booking = booking_presenter.booking
    self.booking_parameters = booking_params(params[:booking])
  end

  def pre_process
    # Extracting booking attachments from params
    self.booking_attachments = user.booking_attachments.with_id(booking_parameters[:booking_attachments])

    self.booking_old_attachments = booking.attachments

    # Remove :invoice_attachments from parameters
    self.booking_parameters.delete(:booking_attachments)

  end

  def process
    old_travel_members = self.booking.travel_members
    self.booking.assign_attributes(booking_parameters)
    self.booking.created_by_user = user
    if self.booking.valid?
      self.booking.save
      # old_travel_members.destroy_all # Jugaad as travel members are being created every time
      add_message :success, 'Successfully Updated Booking'

      booking_old_attachments.update_all(booking_id: nil)
      booking_attachments.update_all(booking_id: self.booking.id)
    else
      add_message :error, self.booking.errors.full_messages
    end
  end

end