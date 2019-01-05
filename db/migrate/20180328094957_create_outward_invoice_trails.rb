class CreateOutwardInvoiceTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :outward_invoice_trails do |t|
      t.integer :action_id, references: "OutwardInvoiceTrailAction", index: true, foreign_key: true
      t.references :customer_account_transaction, index: true, foreign_key: true
      t.references :outward_invoice, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :note
      t.references :amount, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
