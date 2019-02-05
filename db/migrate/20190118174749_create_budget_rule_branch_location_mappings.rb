class CreateBudgetRuleBranchLocationMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_rule_branch_location_mappings do |t|
      t.references :budget_rule, foreign_key: true, null: false, type: :integer
      t.references :branch_location, foreign_key: true, null: false, type: :integer

      t.timestamps
    end
  end
end
