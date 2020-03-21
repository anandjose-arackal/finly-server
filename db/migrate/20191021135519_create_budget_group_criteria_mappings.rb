class CreateBudgetGroupCriteriaMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_group_criteria_mappings do |t|
      t.integer :budget_group_id
      t.integer :budgetable_id, polymorphic: true
      t.string :budgetable_type, polymorphic: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
