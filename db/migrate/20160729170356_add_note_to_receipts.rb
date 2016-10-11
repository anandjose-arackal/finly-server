class AddNoteToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :note, :text
  end
end
