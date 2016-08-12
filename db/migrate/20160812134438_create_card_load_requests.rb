class CreateCardLoadRequests < ActiveRecord::Migration
  def change
    create_table :card_load_requests do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :card, index: true, foreign_key: true, null: false
      t.references :amount, index: true, foreign_key: true, null: false
      t.integer :loaded_by, references: 'user', index: true, foreign_key: true
      t.datetime :loaded_at
      t.string :note
      t.references :card_load_request_status, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
