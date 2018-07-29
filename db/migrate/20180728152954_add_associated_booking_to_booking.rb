class AddAssociatedBookingToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :parent_booking_id, :integer, references: 'Booking', index: true, foreign_key: true
  end
end
