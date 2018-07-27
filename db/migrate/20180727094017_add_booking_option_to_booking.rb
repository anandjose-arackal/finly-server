class AddBookingOptionToBooking < ActiveRecord::Migration
  def change
    BookingStatus.seed_data
  end
end
