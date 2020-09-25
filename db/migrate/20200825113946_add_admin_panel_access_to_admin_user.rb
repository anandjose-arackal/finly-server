class AddAdminPanelAccessToAdminUser < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :admin_panel_access, :boolean, default: true
    add_column :admin_users, :active, :boolean, default: true
  end
end
