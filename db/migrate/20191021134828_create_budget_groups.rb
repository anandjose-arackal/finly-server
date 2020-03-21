class CreateBudgetGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_groups do |t|
      t.integer :company_id, references: "Company", foreign_key: true, index: true
      t.integer :created_by_user_id, references: "User", foreign_key: true, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
