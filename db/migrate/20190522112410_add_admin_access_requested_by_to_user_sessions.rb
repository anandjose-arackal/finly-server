class AddAdminAccessRequestedByToUserSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :admin_access_requested_by, :string
  end
end
