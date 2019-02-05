class DropTableBudgetRulesExpenseTypes < ActiveRecord::Migration[5.2]
  def up
    drop_table :budget_rules_expense_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
