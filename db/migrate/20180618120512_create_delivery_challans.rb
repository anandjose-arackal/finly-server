class CreateDeliveryChallans < ActiveRecord::Migration[4.2]
  def change
    create_table :delivery_challans do |t|
      t.references :company, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :procurement, index: true, foreign_key: true
      t.integer :location_id, references: "BranchLocation", index: true, foreign_key: true
      t.integer :delivery_location_id, references: "BranchLocation", foreign_key: true, index: true
      t.integer :vendor_id, references: "YesBankVendor", foreign_key: true, index: true
      t.references :payment_term, index: true, foreign_key: true
      t.references :procurement_term, index: true, foreign_key: true
      t.references :document_status, index: true, foreign_key: true
      t.string :doc_number
      t.boolean :override_doc_number
      t.string :prefix
      t.string :sequence_start
      t.date :date
      t.date :challan_date
      t.date :due_date
      t.boolean :roundoff_total_enabled
      t.decimal :roundoff_amount, precision: 10, scale: 5

      t.integer :transaction_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :total_before_tax_id, references: "Amount", foreign_key: true, index: true
      t.integer :tax_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :total_after_tax_id, references: "Amount", foreign_key: true, index: true
      t.integer :discount_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :balance_amount_id, references: "Amount", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
