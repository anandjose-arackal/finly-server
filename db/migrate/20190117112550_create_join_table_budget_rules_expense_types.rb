class CreateJoinTableBudgetRulesExpenseTypes < ActiveRecord::Migration[5.2]
  def change
  	create_join_table :budget_rules, :expense_types do |t|
  	  t.index [:budget_rule_id, :expense_type_id], name: 'budget_rule_to_expense_type'
  	  t.index [:expense_type_id, :budget_rule_id], name: 'expense_type_to_budget_rule'
  	end
  end
end

# Specified 'name' to handle this error
# Index name 'index_budget_rules_expense_types_on_budget_rule_id_and_expense_type_id' on table 'budget_rules_expense_types' is too long; the limit is 64 characters

