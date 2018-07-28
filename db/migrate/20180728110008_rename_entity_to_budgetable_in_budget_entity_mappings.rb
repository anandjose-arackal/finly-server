class RenameEntityToBudgetableInBudgetEntityMappings < ActiveRecord::Migration
  def change
    rename_column :budget_entity_mappings, :entity_id, :budgetable_id
    rename_column :budget_entity_mappings, :entity_type, :budgetable_type
  end
end
