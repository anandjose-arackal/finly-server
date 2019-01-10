class RemoveSourceFromDestination < ActiveRecord::Migration[4.2]
  def change
    remove_column :travel_request_destinations, :source
    add_column :travel_request_destinations, :map_id, :string
  end
end
