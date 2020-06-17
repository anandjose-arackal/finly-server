class AddLastActivityAtForAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :last_activity_at, :datetime, index: true
  end
end
