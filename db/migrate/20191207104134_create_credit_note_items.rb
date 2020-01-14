class CreateCreditNoteItems < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_note_item_types do |t|
      t.string :name
    end

    create_table :credit_note_items do |t|
      t.integer :credit_note_id, references: 'CreditNote', foreign_key: true, index: true
      t.integer :item_id, references: 'Item', foreign_key: true, index: true
      t.integer :invoice_item_id, references: 'InvoiceLineItem', foreign_key: true, index: true
      t.integer :category_id, references: 'Category', foreign_key: true, index: true
      t.integer :credit_note_item_type, references: 'CreditNoteItemType', foreign_key: true, index: true

      t.text :comment
      t.string :gl_code
      t.string :hsn_sac

      t.decimal :original_quantity, precision: 20, scale: 5
      t.decimal :revised_quantity, precision: 20, scale: 5
      t.decimal :quantity, precision: 20, scale: 5

      t.decimal :original_rate, precision: 20, scale: 5
      t.decimal :revised_rate, precision: 20, scale: 5
      t.decimal :rate, precision: 20, scale: 5

      t.integer :original_taxable_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :revised_taxable_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :taxable_amount_id, references: 'Amount', foreign_key: true, index: true

      t.integer :original_tax_rate_id, references: 'TaxRate', foreign_key: true, index: true
      t.integer :revised_tax_rate_id, references: 'TaxRate', foreign_key: true, index: true
      t.integer :tax_rate_id, references: 'TaxRate', foreign_key: true, index: true

      t.integer :total, references: 'Amount', foreign_key: true, index: true
      t.timestamps
    end
  end
end

