class CreateBudgetRules < ActiveRecord::Migration
  def change
    create_table :budget_rules do |t|
      t.references :category, index: true, foreign_key: true
      t.references :amount, index: true, foreign_key: true
      t.references :budget_period, index: true, foreign_key: true
      t.references :policy, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
