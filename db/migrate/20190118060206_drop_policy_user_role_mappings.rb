class DropPolicyUserRoleMappings < ActiveRecord::Migration[4.2]
  def change
    drop_table :policy_user_role_mappings
  end
end
