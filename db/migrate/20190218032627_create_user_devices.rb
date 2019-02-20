class CreateUserDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :user_devices do |t|
      t.integer :user_id, index: true, foreign_key: true, references: 'users'
      t.integer :company_id, index: true, foreign_key: true, references: 'companies'
      t.string :fingerprint, index: true
      t.integer :status_id, index: true, foreign_key: true, null: false, references: 'user_device_statuses'
      t.integer :type_id, index: true, foreign_key: true, null: false, references: 'user_device_types'
      t.string :verification_mode, index: true
      t.string :verification_key
      t.datetime :verification_code_sent_at
      t.datetime :verified_at
      t.integer :verification_code_count
      t.integer :verification_failed_attempts

      t.timestamps
    end
    add_column :user_sessions, :user_device_id, :integer, index: true, foreign_key: true, references: 'user_devices', null: false
    rename_table :user_session_webs, :user_device_browsers
    remove_index :user_device_browsers, :user_session_id
    remove_column :user_device_browsers, :user_session_id
    add_column :user_devices, :user_device_browser_id, :integer, index: true, foreign_key: true, references: 'user_device_browsers', null: false
    add_column :user_device_browsers, :is_mobile, :boolean

    ### Moving request specific properties to event ###
    remove_column :user_device_browsers, :current_resolution_height
    remove_column :user_device_browsers, :current_resolution_width
    remove_column :user_device_browsers, :mouse_pos_x
    remove_column :user_device_browsers, :mouse_pos_y

    add_column :user_session_events, :current_resolution_height, :integer
    add_column :user_session_events, :current_resolution_width, :integer
    add_column :user_session_events, :mouse_pos_x, :integer
    add_column :user_session_events, :mouse_pos_y, :integer
    ###
  end
end
