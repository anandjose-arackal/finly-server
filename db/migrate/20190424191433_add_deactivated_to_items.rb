class AddDeactivatedToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :active, :boolean, default: true
    add_index :items, :active
  end
end
