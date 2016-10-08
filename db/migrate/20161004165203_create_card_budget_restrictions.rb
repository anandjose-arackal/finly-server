class CreateCardBudgetRestrictions < ActiveRecord::Migration
  def change
    create_table :card_budget_restrictions do |t|
      t.integer :budget_amount_id, references: 'Amount', index: true, foreign_key: true
      t.references :card, index: true, foreign_key: true
      t.integer :period_id, references: 'BudgetPeriod', index: true, foreign_key: true
      t.references :product_combination, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
