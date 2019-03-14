class CreatePurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_requests do |t|
      t.text :title
      t.integer :user_id, references: "User", foreign_key: true, index: true

      t.timestamps
    end
  end
end
