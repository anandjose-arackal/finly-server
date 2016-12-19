class AddRoleIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :view_role_id, :integer, references: "UserRole", index: true, foreign_key: true
  end
end
