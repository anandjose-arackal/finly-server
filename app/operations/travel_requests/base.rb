class TravelRequests::Base < BaseOperation

  def travel_request_params
    params.require(:travel_request).permit(:name, :policy_id,
                                           destinations_attributes: [
                                               :id, :name, :source,
                                               booking_requests_attributes: [
                                                   :id, :booking_type_id,
                                                   booking_flight_attributes: [
                                                       :id, :journey_date, :journey_source, :journey_destination, :booking_class, :stops
                                                   ],
                                                   booking_car_rental_attributes: [
                                                       :id, :journey_source, :journey_destination, :journey_date,
                                                       :pickup_time, :reservation_start_date, :reservation_end_date,
                                                       :car_type, :pickup_time
                                                   ],
                                                   booking_train_attributes: [
                                                       :id, :booking_class,
                                                       :journey_source, :journey_destination, :journey_date
                                                   ],
                                                   booking_bus_attributes: [
                                                       :id, :booking_class,
                                                       :journey_source, :journey_destination, :journey_date
                                                   ],
                                                   booking_hotel_attributes: [
                                                       :id, :hotel_rating,
                                                       :reservation_start_date, :reservation_end_date, :reservation_destination
                                                   ],
                                                   booking_restaurant_attributes: [
                                                       :id, :restaurant_rating,
                                                       :reservation_destination, :reservation_time, :reservation_date, :restaurant_name
                                                   ],
                                                   booking_custom_attributes: [
                                                       :id, :journey_source, :journey_destination, :journey_date
                                                   ],
                                                   travel_members_attributes: [
                                                       :id, :title, :first_name, :middle_name, :last_name, :child, :age, :email, :mobile_number
                                                   ]
                                               ]
                                           ]
    )

  end

end
