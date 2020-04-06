class RenameAssociationInBudgetGroupCriteria < ActiveRecord::Migration[5.2]
  def change
    rename_column :budget_group_criteria_mappings, :budget_group_id, :budget_group_criterium_id
    change_column :budget_group_criteria_mappings, :budget_group_criterium_id, :integer, references: "BudgetGroupCriterium", foreign_key: true, index: true
  end
end
