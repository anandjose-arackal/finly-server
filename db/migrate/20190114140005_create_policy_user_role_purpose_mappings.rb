class CreatePolicyUserRolePurposeMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :policy_user_role_purpose_mappings do |t|
      t.integer :policy_id, references: 'Policy', foreign_key: true, index: true
      t.integer :user_id, references: 'User', foreign_key: true, index: true
      t.integer :role_id, references: 'UserRole', foreign_key: true, index: true
      t.integer :purpose_id, references: 'Purpose', foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
