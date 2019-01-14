class CreateNewCardRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :new_card_requests do |t|
      t.references :company, index: true, foreign_key: true
      t.integer :requesting_user_id, references: "user", index: true, foreign_key: true
      t.references :card_type, index: true, foreign_key: true
      t.integer :status_id, references: "card_request_status", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
