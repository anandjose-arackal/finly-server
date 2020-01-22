class AddTaxAmountToCnItem < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_note_items, :tax_amount_id, :integer, references: 'Amount', index: true, foreign_key: true
    rename_column :credit_notes, :gst_amount_id, :tax_amount_id
  end
end