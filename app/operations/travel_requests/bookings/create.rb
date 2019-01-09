class TravelRequests::Bookings::Create < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :parent_booking,
                :booking_parameters, :booking_attachments,
                :destination, :travel_request, :request_params

  def authorized_user_types
    [:employee, :travel_manager]
  end

  def pre_validate
    return unless user_present? and params_present?
    if params&.dig(:booking).blank?
      add_message :error, 'Invalid Request'
      return
    end
  end

  def init
    self.request_params = params[:booking]
    unless request_params.is_a?(Array)
      self.request_params = [request_params]
    end
    self.request_params.each do |p|
      p[:booking_status_id] = BookingStatus.id_for(params[:status])
    end
    self.booking_parameters = []
    self.request_params.each do |param|
      booking_param = booking_params(param)
      booking_param[:custom_fields] = param[:custom_fields]
      self.booking_parameters << booking_param
    end

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

  def process

    self.booking_parameters.each do |booking_param|
      # Extracting booking attachments from params
      booking = self.destination.bookings.build(booking_param.except(:booking_attachments, :custom_fields))
      booking.parent_booking = self.parent_booking
      booking.travel_request = self.travel_request
      booking.created_by_user = user
      if booking.request?
        validate_custom_fields(booking, booking_param[:custom_fields])
        return if has_errors?
      end
      if booking.valid?
      else
        add_message :error, booking.errors.full_messages
      end
    end

    return if has_errors?

    self.request_params.each do |param|
      booking_param = booking_params param
      # Extracting booking attachments from params
      booking_attachments = user.company.booking_attachments.with_id(param[:booking_attachments])
      booking = self.destination.bookings.build(booking_param.except(:custom_fields))
      booking.parent_booking = self.parent_booking
      booking.travel_request = self.travel_request
      booking.created_by_user = user
      if booking.request?
        set_custom_fields(booking, param[:custom_fields], false)
      end
      if booking.valid?
        booking.save
        add_message :success, 'Successfully Added Booking'
        booking_attachments.update_all(booking_id: booking.id)
      else
        add_message :error, booking.errors.full_messages
      end
    end
  end

  protected

  def set_custom_fields(booking, custom_fields, save)
    custom_fields = {custom_fields: custom_fields}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(booking, FieldParentType.id_for(:booking_request), custom_fields)
  end

  def validate_custom_fields(booking,custom_fields )
    set_fields = set_custom_fields booking,custom_fields, false
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(booking)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

end