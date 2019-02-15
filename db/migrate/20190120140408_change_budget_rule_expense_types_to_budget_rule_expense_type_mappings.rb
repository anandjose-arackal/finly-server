class ChangeBudgetRuleExpenseTypesToBudgetRuleExpenseTypeMappings < ActiveRecord::Migration[5.2]
  def change
  	rename_table :budget_rule_expense_types, :budget_rule_expense_type_mappings
  end
end
