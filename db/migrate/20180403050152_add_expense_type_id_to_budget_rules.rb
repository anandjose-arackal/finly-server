class AddExpenseTypeIdToBudgetRules < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_rules, :expense_type_id, :integer
  end
end
