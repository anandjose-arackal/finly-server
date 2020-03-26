class CreateTripStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_statuses do |t|
      # t.string :name, index: true, null: false
      # t.boolean :deleted_at, index: true

      # t.timestamps null: false
    end
    TripStatus.seed_data
  end
end
