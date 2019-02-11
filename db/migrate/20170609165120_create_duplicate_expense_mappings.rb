class CreateDuplicateExpenseMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :duplicate_expense_mappings do |t|
      t.integer :expense_id, index: true, foreign_key: true, references: 'Expense', null: false
      t.integer :duplicate_expense_id, foreign_key: true, references: 'Expense', null: false

      t.timestamps null: false
    end
  end
end
