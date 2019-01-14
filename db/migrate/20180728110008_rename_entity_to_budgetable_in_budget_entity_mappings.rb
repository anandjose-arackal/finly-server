class RenameEntityToBudgetableInBudgetEntityMappings < ActiveRecord::Migration[4.2]
  def change
    rename_column :budget_entity_mappings, :entity_id, :budgetable_id
    rename_column :budget_entity_mappings, :entity_type, :budgetable_type
  end
end
