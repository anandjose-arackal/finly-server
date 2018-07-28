class TravelRequests::BookingRequests::Base < TravelRequests::Base

  protected

  def strong_params
    params.require(:booking_request).permit(
        :note,
        booking_flight_attributes: [
            :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:id, :name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_car_rental_attributes: [
            :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:id, :name, :address, :maps_id]},
            :pickup_datetime, :drop_datetime, :pickup_address, :drop_address, :description
        ],
        booking_train_attributes: [
            :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:id, :name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_bus_attributes: [
            :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]}, {to_attributes: [:id, :name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_hotel_attributes: [
            :id, {location_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]}, :checkin_datetime, :checkout_datetime,
            :description
        ],
        booking_restaurant_attributes: [
            :id, {location_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]}, :reservation_datetime, :restaurant_name,
            :number_of_guests, :description
        ],
        booking_custom_attributes: [
            :id, :booking_details, :description
        ],
        travel_members_attributes: [
            :id, :title, :first_name, :middle_name, :last_name, :is_adult, :age, :email, :mobile_number, :gender
        ]
    )
  end

end
