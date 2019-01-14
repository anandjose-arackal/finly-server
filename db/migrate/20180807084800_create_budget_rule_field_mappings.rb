class CreateBudgetRuleFieldMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_rule_field_mappings do |t|
      t.references :budget_rule, index: true, foreign_key: true, null: false
      t.references :field_configuration, index: true, foreign_key: true, null: false
      t.references :field_drop_down_item, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
