class CreateBudgetRules < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_rules do |t|
      t.references :category, index: true, foreign_key: true
      t.references :amount, index: true, foreign_key: true
      t.references :period, index: true, foreign_key: true
      t.references :policy, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
