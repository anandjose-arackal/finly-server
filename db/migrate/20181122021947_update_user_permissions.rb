class UpdateUserPermissions < ActiveRecord::Migration[4.2]
  def change
    add_column :user_permissions, :crud_inventory_item_po, :boolean, default: true
    add_column :user_permissions, :crud_inventory_item_non_po, :boolean, default: true
  end
end
