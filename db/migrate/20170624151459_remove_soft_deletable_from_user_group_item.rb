class RemoveSoftDeletableFromUserGroupItem < ActiveRecord::Migration[4.2]
  def up

    # capturing all user group items that have been soft deleted and destroying them one by one
    UserGroupItem.unscoped.all.each do |item|
      if item.is_deleted
        item.destroy
      end
    end
    remove_column :user_group_items, :is_deleted, :boolean
  end

  def down
    add_column :user_group_items, :is_deleted, :boolean
  end
end
