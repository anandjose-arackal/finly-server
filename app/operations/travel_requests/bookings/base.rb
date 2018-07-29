class TravelRequests::Bookings::Base < TravelRequests::Base

  protected

  def booking_params
    params.require(:booking).permit(
        [:booking_type_id, :note, :booking_status_id,
         booking_flight_attributes: [
             :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
             {to_attributes: [:id, :name, :address, :maps_id]},
             :departure_datetime, :description, :pnr, :airline, :stops, :ticket_number, :arrival_datetime, :terminal,
             {cost_attributes: [:id, :value, :currency_id]}, :booking_class_id
         ],
         booking_car_rental_attributes: [
             :id, {pickup_city_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
             {drop_city_attributes: [:id, :name, :address, :maps_id]},
             :pickup_datetime, :drop_datetime, :pickup_address, :drop_address, :description,
             :car_type, :car_number, :rental_company, {cost_attributes: [:id, :value, :currency_id]}
         ],
         booking_train_attributes: [
             :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
             {to_attributes: [:id, :name, :address, :maps_id]},
             :departure_datetime, :description, :train_number, :pnr, :booking_class,
             :boarding_station, :destination_station, :arrival_datetime, :seat_number,
             {cost_attributes: [:id, :value, :currency_id]}
         ],
         booking_bus_attributes: [
             :id, {from_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
             {to_attributes: [:id, :name, :address, :maps_id]},
             :departure_datetime, :description, :booking_class, :arrival_datetime,
             :boarding_point, :drop_point, {cost_attributes: [:id, :value, :currency_id]}
         ],
         booking_hotel_attributes: [
             :id, {location_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
             :checkin_datetime, :checkout_datetime,
             :number_of_guests, :description, :hotel_name, :hotel_address,
             {cost_attributes: [:id, :value, :currency_id]}
         ],
         booking_restaurant_attributes: [
             :id, {location_attributes: [:id, :name, :address, :latitude, :longitude, :maps_id]},
             :reservation_datetime, :restaurant_name, :restaurant_address,
             :number_of_guests, :description
         ],
         booking_other_attributes: [
             :id, :booking_details, :description, {cost_attributes: [:id, :value, :currency_id]}
         ],
         travel_members_attributes: [
             :id, :title, :first_name, :last_name, :age, :email, :mobile_number, :gender
         ]]
    )
  end

end
