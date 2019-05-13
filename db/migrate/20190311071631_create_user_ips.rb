class CreateUserIps < ActiveRecord::Migration[5.2]
  def change
    create_table :user_ips do |t|
      t.string :ip, null: false, index: true
      t.string :ip_type, null: false, index: true
      t.integer :user_id, index: true, foreign_key: true, null: false, references: 'users'
      t.integer :status_id, index: true, foreign_key: true, null: false, references: 'user_ip_statuses'
      t.string :verification_mode, index: true
      t.string :verification_key
      t.datetime :verification_code_sent_at
      t.datetime :verified_at
      t.integer :verification_code_count
      t.integer :verification_code_failed_attempts

      t.timestamps
    end
    add_column :user_sessions, :user_ip_id, :integer, references: 'user_ips', index: true, foreign_key: true
  end
end
