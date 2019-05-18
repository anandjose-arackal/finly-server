class CreateUserAgentClients < ActiveRecord::Migration[5.2]
  def change
    create_table :user_agent_clients do |t|
      t.string :user_agent, null: false, index: true
      t.integer :user_id, index: true, foreign_key: true, null: false, references: 'users'
      t.integer :status_id, index: true, foreign_key: true, null: false, references: 'user_agent_client_statuses'
      t.string :verification_mode, index: true
      t.string :verification_key
      t.datetime :verification_code_sent_at
      t.datetime :verified_at
      t.integer :verification_code_count
      t.integer :verification_code_failed_attempts

      t.timestamps
    end
    add_column :user_sessions, :user_agent_client_id, :integer, references: 'user_agent_clients', index: true, foreign_key: true
  end
end
