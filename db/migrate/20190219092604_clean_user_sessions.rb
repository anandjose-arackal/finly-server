class CleanUserSessions < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_sessions, :screen_width
    remove_column :user_sessions, :screen_height
    remove_column :user_sessions, :device_fingerprint
    remove_column :user_sessions, :browser
    remove_column :user_sessions, :os
    remove_column :user_sessions, :os_version
    remove_column :user_sessions, :user_agent
    remove_column :user_sessions, :device
    remove_column :user_sessions, :device_type
    remove_column :user_sessions, :platform
    remove_column :user_sessions, :storage_decryption_key
  end
end
