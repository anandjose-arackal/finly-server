class RenameColumnCreditNoteItem < ActiveRecord::Migration[5.2]
  def change
    rename_column :credit_note_items, :credit_note_item_type, :credit_note_item_type_id
    add_column :credit_notes, :submitted_at, :datetime, index: true
    add_column :credit_notes, :approved_at, :datetime, index: true
  end
end
