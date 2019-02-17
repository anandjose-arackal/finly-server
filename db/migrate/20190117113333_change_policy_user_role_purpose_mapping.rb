class ChangePolicyUserRolePurposeMapping < ActiveRecord::Migration[4.2]
  def change
    rename_table :policy_user_role_purpose_mappings, :policy_user_role_mappings
  end
end
