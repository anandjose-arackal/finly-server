class AddGroupIdToUserGroupItemsMapping < ActiveRecord::Migration[4.2]
  def change
    add_reference :user_group_item_mappings, :user_group, index: true, foreign_key: true
  end
end
