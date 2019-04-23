class CreatePurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_request_items do |t|
      # t.references :purchase_request, foreign_key: true, type: :int
      # t.references :inventory_line_item, foreign_key: true, type: :int

      t.integer :purchase_request_id, references: "PurchaseRequest", index: true, foreign_key: true
      t.integer :inventory_line_item_id, references: "Item", index: true, foreign_key: true

      
      t.integer :vendor_id, references: "YesBankVendor", index: true, foreign_key: true
      t.integer :delivery_location_id, references: "BranchLocation", foreign_key: true, index: true

      t.text :purpose
      t.integer :quantity
      t.integer :unit_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :estimated_amount_id, references: "Amount", foreign_key: true, index: true

      t.date :delivery_date, index: true

      t.timestamps
    end
  end
end
