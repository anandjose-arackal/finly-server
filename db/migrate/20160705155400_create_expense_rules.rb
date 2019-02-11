class CreateExpenseRules < ActiveRecord::Migration[4.2]
  def change
    create_table :expense_rules do |t|
      t.integer :greater_than_amount_id, :references => "amount", index: true, foreign_key: true
      t.references :category, index: true, foreign_key: true
      t.integer :days_after

      t.timestamps null: false
    end
  end
end
