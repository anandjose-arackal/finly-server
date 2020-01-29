class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips do |t|
      t.uuid
      t.integer :company_id, references: 'companies', index: true, null: false, foreign_key: true
      t.integer :created_by_id, references: 'users', index: true, null: false, foreign_key: true
      t.integer :status_id, references: 'trip_statuses', index: true, null: false, foreign_key: true
      t.string :trip_id, index: true
      t.integer :policy_id, index: true, foreign_key: true
      t.date :start_date, index: true
      t.date :end_date, index: true
      t.text :purpose
      t.integer :estimated_booking_cost_id, references: "amounts", index: true, foreign_key: true
      t.integer :booking_cost_id, references: "amounts", index: true, foreign_key: true
      t.integer :advance_requested_id, references: "amounts", index: true, foreign_key: true
      t.integer :advance_processed_id, references: "amounts", index: true, foreign_key: true
      t.integer :expenses_total_id, references: "amounts", index: true, foreign_key: true
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
