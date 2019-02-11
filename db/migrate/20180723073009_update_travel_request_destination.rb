class UpdateTravelRequestDestination < ActiveRecord::Migration[4.2]
  def change
    remove_column :travel_request_destinations, :name
    remove_column :travel_request_destinations, :map_id
    add_column :travel_request_destinations, :location_id, :integer, references: 'Location', index: true, foreign_key: true
  end
end
