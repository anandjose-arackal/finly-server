class CreateTripTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_types do |t|
      t.string :name, index: true, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
    TripType.seed_data

    add_reference :trips, :trip_type, index: true, foreign_key: true
  end
end
