class AddRoleIdToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :view_role_id, :integer, references: "UserRole", index: true, foreign_key: true
  end
end
