class TravelRequests::Bookings::Create < TravelRequests::Bookings::Base
  attr_accessor :travel_request, :booking_request, :booking, :booking_parameters, :booking_attachments

  def init
    self.booking_parameters = booking_params

    self.travel_request = TravelRequest.find(params[:travel_request_id]) # todo scope to company
    self.booking_request = ::BookingRequest.find(params[:booking_request_id])

    # todo set created by user

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
    self.booking.created_by_user = user
    if self.booking.valid?
      self.booking.save
      add_message :success, 'Successfully Added Booking'

      booking_attachments.update_all(booking_id: self.booking.id)
    else
      add_message :error, self.booking.errors.full_messages
    end
  end

  def booking_params
    params.require(:booking).permit(
        :booking_type_id, :note, :booking_status_id,
        booking_flight_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]},
            {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description, :pnr, :airline, :stops, :ticket_number, :arrival_datetime, :terminal,
            {cost_attributes: [:value, :currency_id]}, :booking_class_id
        ],
        booking_car_rental_attributes: [
            {pickup_city_attributes: [:name, :address, :latitude, :longitude, :maps_id]},
            {drop_city_attributes: [:name, :address, :maps_id]},
            :pickup_datetime, :drop_datetime, :pickup_address, :drop_address, :description,
            :car_type, :car_number, :rental_company, {cost_attributes: [:value, :currency_id]}
        ],
        booking_train_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]},
            {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description, :train_number, :pnr, :booking_class,
            :boarding_station, :destination_station, :arrival_datetime, :seat_number,
            {cost_attributes: [:value, :currency_id]}
        ],
        booking_bus_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]},
            {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description, :booking_class, :arrival_datetime,
            :boarding_point, :drop_point, {cost_attributes: [:value, :currency_id]}
        ],
        booking_hotel_attributes: [
            {location_attributes: [:name, :address, :latitude, :longitude, :maps_id]},
            :checkin_datetime, :checkout_datetime,
            :number_of_guests, :description, :hotel_name, :hotel_address,
            {cost_attributes: [:value, :currency_id]}
        ],
        booking_restaurant_attributes: [
            {location_attributes: [:name, :address, :latitude, :longitude, :maps_id]},
            :reservation_datetime, :restaurant_name, :restaurant_address,
            :number_of_guests, :description
        ],
        booking_other_attributes: [
            :booking_details, :description, {cost_attributes: [:value, :currency_id]}
        ],
        travel_members_attributes: [
            :title, :first_name, :last_name, :age, :email, :mobile_number, :gender
        ]
    )

  end


end