class SeedBookingStatus < ActiveRecord::Migration[4.2]
  def change
    BookingStatus.seed_data
  end
end
