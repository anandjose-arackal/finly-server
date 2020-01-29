class CreateTripRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_routes do |t|
      t.uuid
      t.string :trip_id, index: true
      t.string :from_location, index: true
      t.string :to_location, index: true
      t.date :depart_on, index: true
      t.date :return_on, index: true
      t.boolean :require_transport, index: true, default: false
      t.boolean :require_hotel, index: true, default: false
      t.boolean :require_local_conveyance, index: true, default: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
