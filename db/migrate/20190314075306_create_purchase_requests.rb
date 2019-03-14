class CreatePurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_requests do |t|
      t.integer :status_id, references: "PurchaseRequestStatus", foreign_key: true, index: true
      t.text :title
      t.integer :location_id, references: "BranchLocation", foreign_key: true, index: true
      t.integer :department_id, references: "Department", foreign_key: true, index: true
      t.integer :policy_id
      t.integer :controlling_level_id
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
