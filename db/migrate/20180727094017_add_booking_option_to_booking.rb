class AddBookingOptionToBooking < ActiveRecord::Migration
  def change
    BookingStatus.seed_data
    TravelRequestTrailAction.seed_data
  end
end
