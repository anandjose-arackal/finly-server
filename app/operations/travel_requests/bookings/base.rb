class TravelRequests::Bookings::Base < TravelRequests::Base

  def booking_params
    params.require(:booking).permit(
        :id, :booking_type_id, booking_attachments: [],
        booking_flight_attributes: [
            :id, :journey_date, :booking_class, :stops, :ticket_number,
            :departure_date, :pnr, :airline, :journey_destination,
            :journey_source
        ],
        booking_train_attributes: [
            :id, :booking_class, :boarding_station_name, :prn,
            :journey_source, :journey_destination, :journey_date, :departure_time, :train_number
        ],
        booking_bus_attributes: [
            :id, :journey_source, :journey_destination, :journey_date, :departure_time, :boarding_point, :booking_class
        ],
        booking_car_rental_attributes: [
            :id, :journey_source, :journey_destination, :journey_date, :pickup_time, :reservation_start_date, :reservation_end_date,
            :car_type, :car_number
        ],
        booking_hotel_attributes: [
            :id, :reservation_end_date, :reservation_start_date, :reservation_time, :hotel_name, :reservation_destination, :hotel_rating
        ],
        booking_restaurant_attributes: [
            :id, :reservation_destination, :reservation_date, :reservation_time, :restaurant_name, :restaurant_rating
        ],
        booking_custom_attributes: [
            :id, :journey_date, :journey_destination, :journey_source
        ],
        travel_members_attributes: [
            :id, :title, :first_name, :middle_name, :last_name, :child, :age, :email, :mobile_number
        ]
    )

  end
end
