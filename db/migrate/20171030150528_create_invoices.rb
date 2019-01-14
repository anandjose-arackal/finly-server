class CreateInvoices < ActiveRecord::Migration[4.2]
  def change
    create_table :invoices do |t|
      t.references :address, index: true, foreign_key: true
      t.date :date
      t.date :due_date
      t.string :invoice_number
      t.decimal :SGST
      t.decimal :CGST
      t.decimal :IGST
      t.integer :tax_type_id, references: "RateType", foreign_key: true, index: true
      t.decimal :discount
      t.integer :discount_type_id, references: "RateType", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
