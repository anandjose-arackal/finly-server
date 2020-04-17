class AddLatLongToLocationQueries < ActiveRecord::Migration[5.2]
  def change
    add_column :map_location_user_queries, :latitude, :decimal, precision: 20, scale: 10
    add_column :map_location_user_queries, :longitude, :decimal, precision: 20, scale: 10
    MapLocationUserQuery.delete_all
  end
end
