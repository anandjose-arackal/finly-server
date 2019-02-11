class CreateCardAssignRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :card_assign_requests do |t|
      t.references :card, index: true, foreign_key: true
      t.integer :card_owner_id, references: 'User', index: true, foreign_key: true, null: false
      t.integer :initiating_resource_id, index: true, null: false
      t.string :initiating_resource_type, index: true, null: false
      t.integer :status_id, references: 'CardAssignRequestStatus', index: true, foreign_key: true, null: false
      t.integer :assigned_by_resource_id, index: true
      t.string :assigned_by_resource_type, index: true
      t.datetime :assigned_on
      t.references :card_program, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
