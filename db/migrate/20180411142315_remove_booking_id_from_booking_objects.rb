class RemoveBookingIdFromBookingObjects < ActiveRecord::Migration[4.2]
  def change
    remove_reference :booking_flights, :booking, index: true, foreign_key: true
    remove_reference :booking_trains, :booking, index: true, foreign_key: true
    remove_reference :booking_buses, :booking, index: true, foreign_key: true
    remove_reference :booking_car_rentals, :booking, index: true, foreign_key: true
    remove_reference :booking_hotels, :booking, index: true, foreign_key: true
    remove_reference :booking_restaurants, :booking, index: true, foreign_key: true

    remove_reference :booking_flights, :booking_request, index: true, foreign_key: true
    remove_reference :booking_trains, :booking_request, index: true, foreign_key: true
    remove_reference :booking_buses, :booking_request, index: true, foreign_key: true
    remove_reference :booking_car_rentals, :booking_request, index: true, foreign_key: true
    remove_reference :booking_hotels, :booking_request, index: true, foreign_key: true
    remove_reference :booking_restaurants, :booking_request, index: true, foreign_key: true
  end
end
