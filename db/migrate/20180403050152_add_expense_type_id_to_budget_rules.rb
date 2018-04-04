class AddExpenseTypeIdToBudgetRules < ActiveRecord::Migration
  def change
    add_column :budget_rules, :expense_type_id, :integer
  end
end
