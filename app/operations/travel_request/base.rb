class TravelRequest::Base < BaseOperation
  attr_accessor :travel_request


  def travel_request_params
    params.require(:travel_request).permit(:name,
                                           destination_attributes: [
                                               :name, :source,
                                               booking_request_attributes: [
                                                   booking_flight_attributes: [
                                                       :departure_date, :journey_source, :journey_destination, :booking_type_id
                                                   ],
                                                   booking_car_rental_attributes: [
                                                       :journey_source
                                                   ]
                                               ]
                                           ]
    )

  end

end
