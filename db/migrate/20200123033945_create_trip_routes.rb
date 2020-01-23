class CreateTripRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_routes do |t|
      t.uuid
      t.references :trip, index: true, null: false, foreign_key: true
      t.integer :from_location_id, references: 'locations', index: true, foreign_key: true
      t.integer :to_location_id, references: 'locations', index: true, foreign_key: true
      t.date :depart_on, index: true
      t.date :return_on, index: true
      t.boolean :require_transport, index: true, default: false
      t.boolean :require_hotel, index: true, default: false
      t.boolean :require_local_conveyance, index: true, default: false
    end
  end
end
