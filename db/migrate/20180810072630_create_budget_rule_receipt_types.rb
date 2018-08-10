class CreateBudgetRuleReceiptTypes < ActiveRecord::Migration
  def change
    create_table :budget_rule_receipt_types do |t|
      t.string :name, index: true, null: false

      t.timestamps null: false
    end
    BudgetRuleReceiptType.seed_data
    add_column :budget_rules, :budget_rule_receipt_type_id, :integer, references: 'BudgetRuleReceiptType', index: true, foreign_key: true
  end
end
