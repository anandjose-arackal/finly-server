class CreateBudgetRuleCategoryMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_rule_category_mappings do |t|
      t.references :budget_rule, index: true, foreign_key: true, null: false
      t.references :category, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    BudgetRule.all.each do |rule|
      if rule.category_id.present?
        rule.budget_rule_category_mappings.create category_id: rule.category_id
      end
    end
    Purpose.seed_data
  end
end
