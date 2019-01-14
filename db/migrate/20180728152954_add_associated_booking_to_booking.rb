class AddAssociatedBookingToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :parent_booking_id, :integer, references: 'Booking', index: true, foreign_key: true
  end
end
