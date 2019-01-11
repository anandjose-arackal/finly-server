class CreatePurchaseOrders < ActiveRecord::Migration[4.2]
  def change
    create_table :purchase_order_statuses do |t|
      t.string :name
      t.timestamps null: false
    end


    create_table :purchase_orders do |t|
      t.references :company, index: true, foreign_key: true
      t.references :procurement, index: true, foreign_key: true

      t.integer :location_id, references: "BranchLocation", foreign_key: true, index: true
      t.integer :delivery_location_id, references: "BranchLocation", foreign_key: true, index: true

      t.integer :vendor_id, references: "YesBankVendor", index: true, foreign_key: true
      t.references :payment_term, index: true, foreign_key: true
      t.references :procurement_term, index: true, foreign_key: true
      t.references :purchase_order_status, index: true, foreign_key: true

      t.string :indent_number
      t.date :indent_date
      t.string :po_number

      t.boolean :override_po_number
      t.string :prefix
      t.string :sequence_start

      t.date :delivery_date

      t.integer :gst_type_id
      t.boolean :inclusive_of_taxes
      t.boolean :roundoff_total_enabled
      t.decimal :roundoff_amount, precision: 10, scale: 5
      t.integer :transaction_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :total_before_tax_id, referenes: "Amount", foreign_key: true, index: true
      t.integer :tax_amount_id, referenes: "Amount", foreign_key: true, index: true
      t.integer :total_after_tax_id, referenes: "Amount", foreign_key: true, index: true
      t.integer :discount_amount_id, referenes: "Amount", foreign_key: true, index: true
      t.integer :balance_amount_id, referenes: "Amount", foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
