class AddIncompleteToUserDeviceBrowsers < ActiveRecord::Migration[5.2]
  def change
    UserDeviceStatus.seed_data
    add_column :user_device_browsers, :status_id, :integer, index: true, null: false, foreign_key: true, references: 'user_device_statuses'
    add_column :user_device_browsers, :message, :text

    add_column :user_sessions, :client_type, :string, index: true
    remove_column :user_sessions, :device_type_id

    add_column :user_devices, :message, :text
  end
end
