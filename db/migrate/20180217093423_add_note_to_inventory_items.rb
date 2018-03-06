class AddNoteToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_line_items, :note, :text
  end
end