class AddTimeToAllBookingRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :booking_flights, :start_time, :text
    add_column :booking_flights, :end_time, :text
    add_column :booking_hotels, :start_time, :text
    add_column :booking_hotels, :end_time, :text
    add_column :booking_trains, :start_time, :text
    add_column :booking_trains, :end_time, :text
    add_column :booking_buses, :start_time, :text
    add_column :booking_buses, :end_time, :text
    add_column :booking_car_rentals, :start_time, :text
    add_column :booking_car_rentals, :end_time, :text
    add_column :booking_restaurants, :start_time, :text
    add_column :booking_restaurants, :end_time, :text
  end
end
