class AddEnabledToPolicyCostCenterMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_cost_center_mappings, :enabled, :boolean
  end
end
