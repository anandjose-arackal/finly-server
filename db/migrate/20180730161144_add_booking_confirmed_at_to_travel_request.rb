class AddBookingConfirmedAtToTravelRequest < ActiveRecord::Migration
  def change
    add_column :travel_requests, :booking_confirmed_at, :datetime
  end
end
