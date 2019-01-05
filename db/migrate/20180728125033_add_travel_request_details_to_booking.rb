class AddTravelRequestDetailsToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :travel_request_id, :integer,
               references: 'TravelRequest', index: true, foreign_key: true, null: false
    add_column :bookings, :destination_id, :integer,
               references: 'TravelRequestDestination', index: true, foreign_key: true, null: false
    add_column :booking_requests, :travel_request_id, :integer,
               references: 'TravelRequest', index: true, foreign_key: true, null: false
  end
end