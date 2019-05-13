class AddAdminUserToUserSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :admin_user_id, :integer, index: true, foreign_key: true, references: 'admin_users'
    add_column :oauth_access_tokens,  :admin_user_id, :integer, index: true, foreign_key: true, references: 'admin_users'

    add_column :admin_users, :authorized_ip, :string, index: true
  end
end
