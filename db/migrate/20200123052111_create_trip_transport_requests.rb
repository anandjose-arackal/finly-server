class CreateTripTransportRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_transport_requests do |t|
      t.uuid
      t.references :trip, index: true, null: false
      t.references :trip_route, index: true, null: false
      t.integer :created_by_id, references: "users", index: true, foreign_key: true, null: false
      t.integer :traveller_id, references: "users", index: true, foreign_key: true, null: false
      t.references :company, index: true
      t.string :mode, index: true
      t.date :depart_on, index: true
      t.string :preferred_timeframe
      t.integer :budget_id, references: "amounts", index: true, foreign_key: true
      t.text :description
    end
    create_table :trip_hotel_requests do |t|
      t.uuid
      t.references :trip, index: true, null: false
      t.references :trip_route, index: true, null: false
      t.integer :created_by_id, references: "users", index: true, foreign_key: true, null: false
      t.integer :traveller_id, references: "users", index: true, foreign_key: true, null: false
      t.references :company, index: true
      t.string :preferred_area
      t.datetime :checkin_at
      t.datetime :checkout_at
      t.text :description
      t.integer :budget_id, references: "amounts", index: true, foreign_key: true
    end
    create_table :trip_local_conveyance_requests do |t|
      t.uuid
      t.references :trip, index: true, null: false
      t.references :trip_route, index: true, null: false
      t.integer :created_by_id, references: "users", index: true, foreign_key: true, null: false
      t.integer :traveller_id, references: "users", index: true, foreign_key: true, null: false
      t.references :company, index: true
      t.string :preferred_area
      t.datetime :checkin_at
      t.datetime :checkout_at
      t.text :description
      t.integer :budget_id, references: "amounts", index: true, foreign_key: true
    end
    Purpose.seed_data
  end
end
