class RemoveGroupIdFromUserGroupItemMapping < ActiveRecord::Migration
  def change
    remove_column :user_group_item_mappings, :group_id
  end
end
