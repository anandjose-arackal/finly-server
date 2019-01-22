class UpdateBookingFields < ActiveRecord::Migration[4.2]
  def change
    remove_column :booking_flights, :booking_class
    remove_column :booking_flights, :departure_date
    remove_column :booking_flights, :journey_destination
    remove_column :booking_flights, :journey_source
    remove_column :booking_flights,:journey_date
    remove_column :booking_flights, :start_time
    remove_column :booking_flights, :end_time
    add_column :booking_flights, :from_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_flights, :to_id,:integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_flights, :departure_datetime, :datetime, index: true
    add_column :booking_flights, :arrival_datetime, :datetime, index: true
    add_column :booking_flights, :description, :text
    add_column :booking_flights, :terminal, :string
    add_column :booking_flights, :cost_id, :integer, references: 'Amount', index: true, foreign_key: true
    add_column :booking_flights, :booking_class_id, :integer, references: 'BookingFlightClass', index: true, foreign_key: true

    remove_column :booking_car_rentals, :journey_source
    remove_column :booking_car_rentals, :journey_destination
    remove_column :booking_car_rentals, :journey_date
    remove_column :booking_car_rentals, :pickup_time
    remove_column :booking_car_rentals, :reservation_start_date
    remove_column :booking_car_rentals, :reservation_end_date
    remove_column :booking_car_rentals, :start_time
    remove_column :booking_car_rentals, :end_time
    add_column :booking_car_rentals, :pickup_city_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_car_rentals, :drop_city_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_car_rentals, :drop_address, :text
    # add_column :booking_car_rentals, :drop_address, :text
    add_column :booking_car_rentals, :pickup_datetime, :datetime, index: true
    add_column :booking_car_rentals, :drop_datetime, :datetime, index: true
    add_column :booking_car_rentals, :rental_company, :string
    add_column :booking_car_rentals, :description, :text
    add_column :booking_car_rentals, :cost_id, :integer, references: 'Amount', index: true, foreign_key: true

    remove_column :booking_trains, :journey_source
    remove_column :booking_trains, :journey_destination
    remove_column :booking_trains, :journey_date
    remove_column :booking_trains, :departure_time
    remove_column :booking_trains, :boarding_station_name
    remove_column :booking_trains, :start_time
    remove_column :booking_trains, :end_time
    add_column :booking_trains, :boarding_city_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_trains, :boarding_station, :string
    add_column :booking_trains, :destination_city_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_trains, :destination_station, :string
    add_column :booking_trains, :departure_datetime, :datetime
    add_column :booking_trains, :arrival_datetime, :datetime
    add_column :booking_trains, :description, :string
    add_column :booking_trains, :seat_number, :string
    add_column :booking_trains, :cost_id, :integer, references: 'Amount', index: true, foreign_key: true

    remove_column :booking_buses, :journey_source
    remove_column :booking_buses, :journey_destination
    remove_column :booking_buses, :journey_date
    remove_column :booking_buses, :departure_time
    remove_column :booking_buses, :start_time
    remove_column :booking_buses, :end_time
    remove_column :booking_buses, :boarding_point
    add_column :booking_buses, :from_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_buses, :to_id, :integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_buses, :departure_datetime, :datetime, null: false
    add_column :booking_buses, :arrival_datetime, :datetime
    add_column :booking_buses, :cost_id, :integer, references: 'Amount', index: true, foreign_key: true
    add_column :booking_buses, :boarding_point, :text
    add_column :booking_buses, :drop_point, :text
    add_column :booking_buses, :description, :text

    remove_column :booking_hotels, :reservation_destination
    remove_column :booking_hotels, :reservation_start_date
    remove_column :booking_hotels, :reservation_time
    remove_column :booking_hotels, :reservation_end_date
    remove_column :booking_hotels, :start_time
    remove_column :booking_hotels, :end_time
    remove_column :booking_hotels, :hotel_rating
    add_column :booking_hotels, :location_id,:integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_hotels, :checkin_datetime, :datetime
    add_column :booking_hotels, :checkout_datetime, :datetime
    add_column :booking_hotels, :description, :text
    add_column :booking_hotels, :hotel_address, :text
    add_column :booking_hotels, :number_of_guests, :integer
    add_column :booking_hotels, :cost_id, :integer, references: 'Amount', index: true, foreign_key: true

    add_column :booking_restaurants, :location_id,:integer, references: 'Location', index: true, foreign_key: true, null: false
    add_column :booking_restaurants, :restaurant_address, :text
    add_column :booking_restaurants, :reservation_datetime, :datetime
    add_column :booking_restaurants, :number_of_guests, :integer
    add_column :booking_restaurants, :description, :text
    remove_column :booking_restaurants, :restaurant_rating
    remove_column :booking_restaurants, :reservation_destination
    remove_column :booking_restaurants, :reservation_date
    remove_column :booking_restaurants, :reservation_time
    remove_column :booking_restaurants, :start_time
    remove_column :booking_restaurants, :end_time

    add_column :booking_customs, :booking_details, :text
    add_column :booking_customs, :description, :text
    add_column :booking_customs, :cost_id, :integer, references: 'Amount', index: true, foreign_key: true
    remove_column :booking_customs, :journey_date
    remove_column :booking_customs, :journey_destination
    remove_column :booking_customs, :journey_source
    remove_column :booking_customs, :start_time
    remove_column :booking_customs, :end_time
  end
end
