class TravelRequests::Base < BaseOperation

  def travel_request_params
    params.require(:travel_request).permit(:name, :policy_id,
                                           destinations_attributes: [
                                               :name, :source,
                                               booking_requests_attributes: [
                                                   :booking_type_id,
                                                   booking_flight_attributes: [
                                                       :departure_date, :journey_source, :journey_destination
                                                   ],
                                                   booking_car_rental_attributes: [
                                                       :journey_source, :journey_destination, :journey_date,
                                                       :pickup_time, :reservation_start_date, :reservation_end_date,
                                                       :car_type, :pickup_time
                                                   ],
                                                   booking_train_attributes: [
                                                       :journey_source, :journey_destination, :journey_date
                                                   ],
                                                   booking_bus_attributes: [
                                                       :journey_date, :journey_destination, :journey_date
                                                   ],
                                                   booking_hotel_attributes: [
                                                       :reservation_start_date, :reservation_end_date, :reservation_destination
                                                   ],
                                                   booking_restaurant_attributes: [
                                                       :reservation_destination, :reservation_time, :reservation_date, :restaurant_name
                                                   ]
                                               ]
                                           ]
    )

  end

end
