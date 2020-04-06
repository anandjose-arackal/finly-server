class CreateBudgetGroupCriteria < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_group_criteria do |t|
      t.string :name
      t.integer :budget_group_id, references: "BudgetGroup", foreign_key: true, index: true
      t.string :ancestry
      t.datetime :deleted, index: true

      t.timestamps
    end
  end
end
