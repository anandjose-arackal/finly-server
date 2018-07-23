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
            {from_attributes: [:name, :address, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_car_rental_attributes: [
            {from_attributes: [:name, :address, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :pickup_datetime, :drop_datetime, :pickup_address, :drop_address, :description
        ],
        booking_train_attributes: [
            {from_attributes: [:name, :address, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_bus_attributes: [
            {from_attributes: [:name, :address, :maps_id]}, {to_attributes: [:name, :address, :maps_id]},
            :departure_datetime, :description
        ],
        booking_hotel_attributes: [
            {location_attributes: [:name, :address, :maps_id]}, :checkin_datetime, :checkout_datetime,
            :description
        ],
        booking_restaurant_attributes: [
            {location_attributes: [:name, :address, :maps_id]}, :reservation_datetime, :restaurant_name,
            :number_of_guests, :description
        ],
        booking_custom_attributes: [
            :booking_details, :description
        ],
        travel_members_attributes: [
            :title, :first_name, :middle_name, :last_name, :is_adult, :age, :email, :mobile_number, :gender
        ]
    )
  end

  # def strong_params
  #   params.require(:booking_request).permit(
  #       :booking_type_id, :note,
  #       booking_flight_attributes: [
  #           :id, :journey_date, :journey_source, :journey_destination,
  #           :booking_class, :start_time, :end_time, :stops
  #       ],
  #       booking_car_rental_attributes: [
  #           :id, :journey_source, :journey_destination, :journey_date,
  #           :pickup_time, :reservation_start_date, :reservation_end_date,
  #           :start_time, :end_time,
  #           :car_type, :pickup_time, :pickup_address
  #       ],
  #       booking_train_attributes: [
  #           :id, :booking_class,
  #           :journey_source, :journey_destination, :journey_date,
  #           :start_time, :end_time,
  #       ],
  #       booking_bus_attributes: [
  #           :id, :booking_class,
  #           :journey_source, :journey_destination, :journey_date,
  #           :start_time, :end_time,
  #       ],
  #       booking_hotel_attributes: [
  #           :id, :hotel_rating,
  #           :reservation_start_date, :reservation_end_date, :reservation_destination,
  #           :start_time, :end_time,
  #       ],
  #       booking_restaurant_attributes: [
  #           :id, :restaurant_rating,
  #           :reservation_destination, :reservation_time, :reservation_date, :restaurant_name,
  #           :start_time, :end_time,
  #       ],
  #       booking_custom_attributes: [
  #           :id, :journey_source, :journey_destination, :journey_date,
  #           :start_time, :end_time,
  #       ],
  #       travel_members_attributes: [
  #           :id, :title, :first_name, :middle_name, :last_name, :child, :age, :email, :mobile_number, :gender, :_destroy
  #       ]
  #   )
  # end

end