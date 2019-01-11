class ChangeBookingAssociations < ActiveRecord::Migration[4.2]
  def change
    add_column :booking_flights, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
    add_column :booking_buses, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
    add_column :booking_trains, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
    add_column :booking_car_rentals, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
    add_column :booking_hotels, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
    add_column :booking_restaurants, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
    add_column :booking_others, :booking_id, :integer, references: "Booking", foreign_key: true, index: true

    begin
      BookingFlight.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
      BookingBus.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
      BookingTrain.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
      BookingCarRental.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
      BookingHotel.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
      BookingRestaurant.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
      BookingOther.all.each do |b|
        b.update(booking_id: b.parent_id)
      end
    rescue StandardError => e
      # nothing to do!
    end
  end
end
