class CreateOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    create_table :outward_invoices do |t|
      t.references :customer, index: true, foreign_key: true
      t.date :invoice_date
      t.date :invoice_due_date
      t.references :amount, index: true, foreign_key: true
      t.decimal :discount, precision: 10, scale: 5
      t.decimal :tax, precision: 10, scale: 5
      t.integer :discount_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :tax_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :original_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :paid_amount_id, references: "Amount", foreign_key: true, index: true
      t.decimal :advance, precision: 10, scale: 5
      t.integer :freight_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :tds_amount_id, references: "Amount", foreign_key: true, index: true
      t.references :category
      t.integer :balance_due_id, references: "Amount", foreign_key: true, index: true
      t.decimal :roundoff_amount, precision: 10, scale: 5

      t.timestamps null: false
    end

    # seeding Purposes and FieldParentType
    Purpose.seed_data
    FieldParentType.create(name: "outward_invoice")
  end
end