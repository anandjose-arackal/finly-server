class AddPolicyIdNilToTeamMappings < ActiveRecord::Migration[4.2]
  def change
    change_column_null :user_manager_mappings, :policy_id, false
  end
end
