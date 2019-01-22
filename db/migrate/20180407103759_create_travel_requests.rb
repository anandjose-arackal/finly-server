class CreateTravelRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_requests do |t|
      t.references :user, index: true, foreign_key: true
      t.references :policy, index: true, foreign_key: true
      t.string :name
      t.date :required_by_date
      t.text :note

      t.integer :status_id, references: 'travel_request_status', index: true, foreign_key: true, null: false
      t.integer :controlling_user_id, references: 'user', index: true, foreign_key: true
      t.integer :controlling_user_role_id, :references => 'user_role', index: true, foreign_key: true
      t.integer :controlling_for_user_id, references: 'user', index: true, foreign_key: true
      t.integer :controlling_for_user_role_id, :references => 'user_role', index: true, foreign_key: true

      t.datetime :submitted_at, limit: 6

      t.timestamps null: false
    end
  end
end
