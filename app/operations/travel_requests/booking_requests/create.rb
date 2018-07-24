class TravelRequests::BookingRequests::Create < TravelRequests::BookingRequests::Base
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

    self.booking_request = self.destination.booking_requests.build strong_params
  end

  def validate
    unless self.booking_request.valid?
      add_message :error, self.booking_request.errors.full_messages
    end
  end

  def process
    unless self.booking_request.save
      add_message :error, self.booking_request.errors.full_messages
    end
  end

  protected

  def strong_params
    params.require(:booking_request).permit(
        :booking_type_id, :note,
        booking_flight_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_car_rental_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :pickup_datetime, :drop_datetime, :pickup_address, :drop_address, :description
        ],
        booking_train_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_bus_attributes: [
            {from_attributes: [:name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_hotel_attributes: [
            {location_attributes: [:name, :address, :latitude, :longitude, :maps_id]}, :checkin_datetime, :checkout_datetime,
            :number_of_guests, :description
        ],
        booking_restaurant_attributes: [
            {location_attributes: [:name, :address, :latitude, :longitude, :maps_id]}, :reservation_datetime, :restaurant_name,
            :number_of_guests, :description
        ],
        booking_custom_attributes: [
            :booking_details, :description
        ],
        travel_members_attributes: [
            :title, :first_name, :last_name, :age, :email, :mobile_number, :gender
        ]
    )
  end

end