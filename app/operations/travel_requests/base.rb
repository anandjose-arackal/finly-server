class TravelRequests::Base < BaseOperation

  def travel_request_params
    params.require(:travel_request).permit(:name, :policy_id, :report_id, :money_request_id, :note, :created_by_id, :modified_by_id,
                                           destinations_attributes: [
                                               :id, :name, :source, :_destroy,
                                               booking_requests_attributes: [
                                                   :id, :booking_type_id, :note, :_destroy,
                                                   booking_flight_attributes: [
                                                       :id, :journey_date, :journey_source, :journey_destination, :booking_class, :start_time, :end_time, :stops
                                                   ],
                                                   booking_car_rental_attributes: [
                                                       :id, :journey_source, :journey_destination, :journey_date,
                                                       :pickup_time, :reservation_start_date, :reservation_end_date,
                                                       :start_time, :end_time,
                                                       :car_type, :pickup_time, :pickup_address
                                                   ],
                                                   booking_train_attributes: [
                                                       :id, :booking_class,
                                                       :journey_source, :journey_destination, :journey_date,
                                                       :start_time, :end_time,
                                                   ],
                                                   booking_bus_attributes: [
                                                       :id, :booking_class,
                                                       :journey_source, :journey_destination, :journey_date,
                                                       :start_time, :end_time,
                                                   ],
                                                   booking_hotel_attributes: [
                                                       :id, :hotel_rating,
                                                       :reservation_start_date, :reservation_end_date, :reservation_destination,
                                                       :start_time, :end_time,
                                                   ],
                                                   booking_restaurant_attributes: [
                                                       :id, :restaurant_rating,
                                                       :reservation_destination, :reservation_time, :reservation_date, :restaurant_name,
                                                       :start_time, :end_time,
                                                   ],
                                                   booking_custom_attributes: [
                                                       :id, :journey_source, :journey_destination, :journey_date,
                                                       :start_time, :end_time,
                                                   ],
                                                   travel_members_attributes: [
                                                       :id, :title, :first_name, :middle_name, :last_name, :child, :age, :email, :mobile_number, :gender, :_destroy
                                                   ]
                                               ]
                                           ]
    )

  end

end
