class AddSoftDeletableToUserGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :user_groups, :is_deleted, :boolean, default: false
    add_column :user_group_items, :is_deleted, :boolean, default: false
    add_column :user_group_item_mappings, :is_deleted, :boolean, default: false
  end
end
