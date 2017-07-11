class CreateCardAssignRequests < ActiveRecord::Migration
  def change
    create_table :card_assign_requests do |t|
      t.references :card, index: true, foreign_key: true
      t.integer :card_owner_id, references: 'User', index: true, foreign_key: true, null: false
      t.integer :initiating_user_id, index: true, null: false
      t.string :initiating_user_type, index: true, null: false
      t.integer :status_id, references: 'CardAssignRequestStatus', index: true, foreign_key: true, null: false
      t.integer :request_action_user_id
      t.string :request_action_user_type
      t.datetime :closed_at
      t.references :card_program, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
