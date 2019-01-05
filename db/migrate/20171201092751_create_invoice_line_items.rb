class CreateInvoiceLineItems < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_line_items do |t|
      t.references :invoice, index: true, foreign_key: true
      t.string :name
      t.integer :quantity
      t.decimal :rate
      t.decimal :tax
      t.decimal :tds
      t.decimal :discount
      t.references :category, index: true, foreign_key: true
      t.integer :tax_type_id, references: "Amount", foreign_key: true, index: true
      t.integer :tax_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :tds_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :discount_amount_id, references: "Amount", foreign_key: true, index: true
      t.references :amount

      t.timestamps null: false
    end
  end
end
