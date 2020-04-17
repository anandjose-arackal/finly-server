class AddLatLongToMapLocationDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :map_location_details, :latitude, :decimal, precision: 20, scale: 10
    add_column :map_location_details, :longitude, :decimal, precision: 20, scale: 10
    MapLocationDetail.delete_all
    MapLocationSearch.delete_all
    MapLocationUserQuery.delete_all
  end
end
