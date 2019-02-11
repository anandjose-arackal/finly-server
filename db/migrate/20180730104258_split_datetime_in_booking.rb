class SplitDatetimeInBooking < ActiveRecord::Migration[4.2]
  def change
    remove_column :booking_flights, :departure_datetime
    remove_column :booking_flights, :arrival_datetime
    add_column :booking_flights, :departure_date, :date
    add_column :booking_flights, :departure_time, :time
    add_column :booking_flights, :arrival_date, :date
    add_column :booking_flights, :arrival_time, :time

    # remove_column :booking_car_rentals, :pickup_datetime
    # remove_column :booking_car_rentals, :drop_datetime
    add_column :booking_car_rentals, :pickup_date, :date
    add_column :booking_car_rentals, :pickup_time, :time
    add_column :booking_car_rentals, :drop_date, :date
    add_column :booking_car_rentals, :drop_time, :time

    remove_column :booking_trains, :departure_datetime
    remove_column :booking_trains, :arrival_datetime
    add_column :booking_trains, :departure_date, :date
    add_column :booking_trains, :departure_time, :time
    add_column :booking_trains, :arrival_date, :date
    add_column :booking_trains, :arrival_time, :time

    remove_column :booking_buses, :departure_datetime
    remove_column :booking_buses, :arrival_datetime
    add_column :booking_buses, :departure_date, :date
    add_column :booking_buses, :departure_time, :time
    add_column :booking_buses, :arrival_date, :date
    add_column :booking_buses, :arrival_time, :time

    remove_column :booking_restaurants, :reservation_datetime
    add_column :booking_restaurants, :reservation_date, :date
    add_column :booking_restaurants, :reservation_time, :time

    remove_column :booking_hotels, :checkin_datetime
    remove_column :booking_hotels, :checkout_datetime
    add_column :booking_hotels, :checkin_date, :date
    add_column :booking_hotels, :checkin_time, :time
    add_column :booking_hotels, :checkout_date, :date
    add_column :booking_hotels, :checkout_time, :time
  end
end