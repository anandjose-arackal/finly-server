class ChangeScaleInLocations < ActiveRecord::Migration[4.2]
  def change
    change_column :locations, :latitude, :decimal, precision: 30, scale: 15
    change_column :locations, :longitude, :decimal, precision: 30, scale: 15
  end
end
