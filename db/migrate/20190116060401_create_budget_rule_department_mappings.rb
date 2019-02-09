class CreateBudgetRuleDepartmentMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_rule_department_mappings do |t|
      t.references :budget_rule, index: true, foreign_key: true, null: false, type: :integer
      t.references :department, index: true, foreign_key: true, null: false, type: :integer

      t.timestamps
    end
  end
end
