class AddMapsIdToLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :maps_id, :string
  end
end
