class AddMapsIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :maps_id, :string
  end
end
