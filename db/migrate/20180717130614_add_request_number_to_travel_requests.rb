class AddRequestNumberToTravelRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :trip_id, :string
    add_column :travel_requests, :purpose_of_travel, :text
  end
end
