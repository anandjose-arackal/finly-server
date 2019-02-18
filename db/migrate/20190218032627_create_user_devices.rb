class CreateUserDevices < ActiveRecord::Migration[5.2]
  def change
    UserSession.destroy_all
    UserSessionWeb.destroy_all
    create_table :user_devices do |t|
      t.integer :user_id, index: true, foreign_key: true, references: 'users'
      t.integer :company_id, index: true, foreign_key: true, references: 'companies'
      t.string :fingerprint, index: true
      t.integer :status_id, index: true, foreign_key: true, null: false, references: 'user_device_statuses'
      t.string :verification_mode, index: true
      t.string :verification_key
      t.datetime :verification_code_sent_at
      t.datetime :verified_at
      t.integer :verification_code_count
      t.integer :verification_failed_attempts

      t.timestamps
    end
    add_column :user_sessions, :user_device_id
    rename_table :user_session_webs, :user_device_webs
    remove_column :user_device_webs, :user_session_id
    add_column :user_device_webs, :user_device_id, :integer, index: true, foreign_key: true, references: 'user_devices', null: false
  end
end
