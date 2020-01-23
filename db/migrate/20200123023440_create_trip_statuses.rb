class CreateTripStatuses < ActiveRecord::Migration[5.2]
  def change
    drop_table :trip_statuses
    create_table :trip_statuses do |t|
      t.string :name, index: true, null: false
    end
    TripStatus.seed_data
  end
end
