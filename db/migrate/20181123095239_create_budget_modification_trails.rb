class CreateBudgetModificationTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_modification_trails do |t|
      t.references :budget, index: true, foreign_key: true
      t.integer :action_user_id, references: "User", foreign_key: true, index: true
      t.integer :action_id, references: "BudgetModificationAction", references: true, index: true

      t.timestamps null: false
    end
  end
end
