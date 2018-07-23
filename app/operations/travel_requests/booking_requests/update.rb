class TravelRequests::BookingRequests::Update < TravelRequests::BookingRequests::Base
  attr_accessor :destination, :booking_request

  def pre_validate
    user_present? and params_present?
  end

  def init
    requests_presenter = TravelRequests::BookingRequests::Show.(user, {
        travel_request_id: params[:travel_request_id],
        destination_id: params[:destination_id],
        id: params[:id],
        view: params[:view]
    })
    unless requests_presenter.success?
      add_message :error, requests_presenter.messages[:error]
      return
    end
    self.destination = requests_presenter.destination
    self.booking_request = requests_presenter.booking_request
    self.booking_request&.assign_attributes strong_params
  end

  def validate
    if self.booking_request.blank?
      add_message :error, 'Booking request not found'
      return
    end
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