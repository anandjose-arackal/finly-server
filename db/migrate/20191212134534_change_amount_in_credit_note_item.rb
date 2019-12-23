class ChangeAmountInCreditNoteItem < ActiveRecord::Migration[5.2]
  def change
    rename_column :credit_note_items, :total, :total_amount_id
    add_column :credit_note_items, :deleted_at, :datetime, index: true
  end
end
