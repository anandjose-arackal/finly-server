class AddRuleToGatekeeperBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :gatekeeper_blocks, :rule, :string
    add_column :user_sessions, :device_type_id, :integer, references: 'user_device_types', index: true, foreign_key: true
  end
end
