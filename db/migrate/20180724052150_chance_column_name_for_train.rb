class ChanceColumnNameForTrain < ActiveRecord::Migration[4.2]
  def change
    rename_column :booking_trains, :boarding_city_id, :from_id
    rename_column :booking_trains, :boarding_station, :boarding_station
    rename_column :booking_trains, :destination_city_id, :to_id
    rename_column :booking_trains, :destination_station, :destination_station
  end
end
