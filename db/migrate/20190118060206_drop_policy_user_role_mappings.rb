class DropPolicyUserRoleMappings < ActiveRecord::Migration
  def change
    drop_table :policy_user_role_mappings
  end
end
