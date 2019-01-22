class AddNoteToReceipts < ActiveRecord::Migration[4.2]
  def change
    add_column :receipts, :note, :text
  end
end
