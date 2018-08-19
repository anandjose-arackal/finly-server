class RemoveSourceFromDestination < ActiveRecord::Migration
  def change
    remove_column :travel_request_destinations, :source
    add_column :travel_request_destinations, :map_id, :string
  end
end
