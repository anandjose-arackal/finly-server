class CreateBudgetRuleExpenseTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_rule_expense_types do |t|
      t.references :budget_rule, foreign_key: true, null: false, type: :integer, index: true
      t.references :expense_type, foreign_key: true, null: false, type: :integer, index: true

      t.timestamps
    end
  end
end
