class AddPolicyIdNilToTeamMappings < ActiveRecord::Migration
  def change
    change_column_null :user_manager_mappings, :policy_id, false
  end
end
