class AddAdminUserUserSessionReason < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :admin_access_reason, :text
    add_column :user_sessions, :admin_access_reason_details, :text
  end
end
