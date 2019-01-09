class SeedBookingStatus < ActiveRecord::Migration
  def change
    BookingStatus.seed_data
  end
end
