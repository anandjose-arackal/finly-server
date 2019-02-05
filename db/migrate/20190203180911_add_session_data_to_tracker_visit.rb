class AddSessionDataToTrackerVisit < ActiveRecord::Migration[5.2]
  def change
    rename_table :tracker_visits, :user_sessions
    rename_table :tracker_events, :user_session_events
    rename_table :tracker_notifications, :user_session_notifications
    rename_column :user_session_events, :tracker_visit_id, :user_session_id
    add_column :user_sessions, :access_token_id, :integer, references: 'oauth_access_tokens', index: true, foreign_key: true
    add_column :user_sessions, :device_fingerprint, :string
    add_column :user_sessions, :storage_decryption_key, :string
    add_column :user_sessions, :last_request_at, :datetime, index: true
    add_column :user_sessions, :duration, :integer, limit: 6
    add_column :user_sessions, :status_id, :integer, references: 'user_session_statuses', index: true, foreign_key: true
    add_column :user_sessions, :message, :string
    add_column :user_sessions, :login_username, :string
    add_column :user_sessions, :screen_width, :integer
    add_column :user_sessions, :screen_height, :integer
    add_column :user_sessions, :mouse_pos_x, :decimal, precision: 20, scale: 10
    add_column :user_sessions, :mouse_pos_y, :decimal, precision: 20, scale: 10
    add_column :user_sessions, :scroll_x, :decimal, precision: 20, scale: 10
    add_column :user_sessions, :scroll_y, :decimal, precision: 20, scale: 10
    add_column :user_session_events, :status_id, :integer, references: 'user_session_statuses', index: true, foreign_key: true
    add_column :user_session_events, :message, :string
    add_column :user_session_events, :response_code, :integer
    add_column :user_session_notifications, :status_id, :integer, references: 'user_session_statuses', index: true, foreign_key: true
    add_column :user_session_notifications, :message, :string
  end
end
