class UpdateUserPermissions < ActiveRecord::Migration
  def change
    add_column :user_permissions, :crud_inventory_item_po, :boolean, default: true
    add_column :user_permissions, :crud_inventory_item_non_po, :boolean, default: true
  end
end
