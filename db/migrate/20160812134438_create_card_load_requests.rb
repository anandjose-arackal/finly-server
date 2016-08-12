class CreateCardLoadRequests < ActiveRecord::Migration
  def change
    create_table :card_load_requests do |t|
      t.integer :prepaid_card_id, references: 'card', index: true, foreign_key: true
      t.integer :load_amount_id, references: 'amount', index: true, foreign_key: true
      t.integer :loaded_by, references: 'user', index: true, foreign_key: true
      t.datetime :loaded_at
      t.string :note
      t.references :card_load_request_status, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
