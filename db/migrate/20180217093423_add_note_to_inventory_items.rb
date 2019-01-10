class AddNoteToInventoryItems < ActiveRecord::Migration[4.2]
  def change
    add_column :inventory_line_items, :note, :text
  end
end