class AddBookingsToTravelRequestComments < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :booking_id, :integer, references: "Booking", foreign_key: true, index: true
  end
end