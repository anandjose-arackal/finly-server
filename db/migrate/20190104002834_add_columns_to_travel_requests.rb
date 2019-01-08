class AddColumnsToTravelRequests < ActiveRecord::Migration
  def change
    add_column :travel_requests, :created_by_id, :integer
    add_index :travel_requests, :created_by_id
    add_column :travel_requests, :modified_by_id, :integer
    add_index :travel_requests, :modified_by_id
  end
end
