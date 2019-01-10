class AddBookingConfirmedAtToTravelRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :booking_confirmed_at, :datetime
  end
end
