class AddCreditNotesFields < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_notes, :cn_gross_receivable_amount, :decimal,precision: 20, scale: 10
    add_column :credit_notes, :cn_tax_amount, :decimal,precision: 20, scale: 10
    add_column :credit_notes, :cn_tds_amount, :decimal,precision: 20, scale: 10
    add_column :credit_notes, :cn_net_receivable_amount, :decimal,precision: 20, scale: 10
    add_column :credit_notes, :cn_previously_adjusted_amount, :decimal,precision: 20, scale: 10
    add_column :credit_notes, :cn_net_adjustable_amount, :decimal,precision: 20, scale: 10
    add_column :credit_notes, :cn_roundoff_amount, :decimal,precision: 20, scale: 10
    add_column :credit_note_items, :cn_original_taxable_amount, :decimal,precision: 20, scale: 10
    add_column :credit_note_items, :cn_taxable_amount, :decimal,precision: 20, scale: 10
    add_column :credit_note_items, :cn_total_amount, :decimal,precision: 20, scale: 10
    add_column :credit_note_items, :original_item_tax_amount, :decimal,precision: 20, scale: 10
    add_column :credit_note_items, :item_tax_amount, :decimal,precision: 20, scale: 10
  end
end
