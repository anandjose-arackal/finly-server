class CreateBudgets < ActiveRecord::Migration[4.2]
  def change
    create_table :budgets do |t|
      t.string :name
      t.references :period, index: true, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :budget_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :spent_amount_id, references: "Amount", foreign_key: true, index: true

      t.references :budgetable, polymorphic: true, index: true, null: false
      t.boolean :is_deleted, default: false
      t.timestamps null: false
    end
  end
end