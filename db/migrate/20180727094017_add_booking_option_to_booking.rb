class AddBookingOptionToBooking < ActiveRecord::Migration[4.2]
  def change
    BookingStatus.seed_data
    TravelRequestTrailAction.seed_data
  end
end
