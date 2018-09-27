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

    if self.booking.request?
      # Set custom fields
      custom_fields = {custom_fields: (params[:custom_fields] || params&.dig(:booking, :custom_fields))}
      custom_fields[:save] = false
      # custom_fields[:reset_fields] = true
      set_fields = CustomField::SetFields.(self.booking, FieldParentType.id_for(:booking_request), custom_fields)
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      # validating the custom fields here
      valid = CustomField::Validate.(self.booking)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return false
      end
    end
    if self.booking.valid?
      old_travel_members.without_id_nil.destroy_all # Jugaad as travel members are being created every time
      self.booking.save
      add_message :success, 'Successfully Updated Booking'

      booking_old_attachments.update_all(booking_id: nil)
      booking_attachments.update_all(booking_id: self.booking.id)
    else
      add_message :error, self.booking.errors.full_messages
    end
  end

end