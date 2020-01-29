class CreateTripTransportRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_transport_requests do |t|
      t.uuid
      t.string :trip_id, index: true
      t.integer :created_by_id, references: "users", index: true, foreign_key: true
      t.integer :traveller_id, references: "users", index: true, foreign_key: true
      t.references :company, index: true
      t.string :from_location, index: true
      t.string :to_location, index: true
      t.string :mode, index: true
      t.date :depart_on, index: true
      t.string :preferred_timeframe
      t.integer :budget_id, references: "amounts", index: true, foreign_key: true
      t.text :description
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
    create_table :trip_hotel_requests do |t|
      t.uuid
      t.string :trip_id, index: true
      t.integer :created_by_id, references: "users", index: true, foreign_key: true
      t.integer :traveller_id, references: "users", index: true, foreign_key: true
      t.references :company, index: true
      t.string :location
      t.string :preferred_area
      t.datetime :checkin_at
      t.datetime :checkout_at
      t.text :description
      t.integer :budget_id, references: "amounts", index: true, foreign_key: true
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
    create_table :trip_local_conveyance_requests do |t|
      t.uuid
      t.string :trip_id, index: true
      t.integer :created_by_id, references: "users", index: true, foreign_key: true
      t.integer :traveller_id, references: "users", index: true, foreign_key: true
      t.references :company, index: true
      t.string :location
      t.string :pickup_area
      t.datetime :pickup_at
      t.datetime :drop_at
      t.text :description
      t.integer :budget_id, references: "amounts", index: true, foreign_key: true
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
    Purpose.seed_data
  end
end
