class ChangeBookingRequestAssociation < ActiveRecord::Migration[4.2]
  def change
    # Remove booking_type reference from booking objects
    remove_reference :booking_flights, :booking_type, index: true, foreign_key: true
    remove_reference :booking_trains, :booking_type, index: true, foreign_key: true
    remove_reference :booking_buses, :booking_type, index: true, foreign_key: true
    remove_reference :booking_car_rentals, :booking_type, index: true, foreign_key: true
    remove_reference :booking_hotels, :booking_type, index: true, foreign_key: true
    remove_reference :booking_restaurants, :booking_type, index: true, foreign_key: true

    # Add polymorphic relationship with booking objects with booking and booking_request
    add_reference :booking_flights, :parent, polymorphic: true, index: true
    add_reference :booking_trains, :parent, polymorphic: true, index: true
    add_reference :booking_buses, :parent, polymorphic: true, index: true
    add_reference :booking_car_rentals, :parent, polymorphic: true, index: true
    add_reference :booking_hotels, :parent, polymorphic: true, index: true
    add_reference :booking_restaurants, :parent, polymorphic: true, index: true

    # Add booking_type to booking and booking request
    add_reference :bookings, :booking_type, index: true, foreign_key: true
    add_reference :booking_requests, :booking_type, index: true, foreign_key: true

  end
end
