class CreateCardUpdateRequests < ActiveRecord::Migration
  def change
    create_table :card_update_requests do |t|
      t.references :card, index: true, foreign_key: true
      t.integer :card_owner_id
      t.integer :initiating_user_id
      t.string :initiating_user_type
      t.integer :status_id
      t.integer :request_action_user_id
      t.string :request_action_user_type
      t.datetime :closed_at
      t.references :card_program, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
