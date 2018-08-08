class RenameBudgetEntityTrailsToBudgetCriteriaTrails < ActiveRecord::Migration
  def change
    rename_table :budget_entity_mappings, :budget_criteria_mappings
  end
end
