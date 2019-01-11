class RemoveUnnecessaryIdsFromTravelRequests < ActiveRecord::Migration[4.2]
  def change
    remove_column :travel_requests, :booking_id, :integer
    remove_column :travel_requests, :booking_request_id, :integer
    add_column :travel_request_comments, :booking_id, :integer
    add_column :travel_request_comments, :booking_request_id, :integer
  end
end
