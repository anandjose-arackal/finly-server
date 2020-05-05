class CreateFormEntityConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :form_condition_types do |t|
      t.string :name, index: true, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
    create_table :form_rule_types do |t|
      t.string :name, index: true, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
    create_table :form_conditions do |t|
      t.uuid :uuid
      t.references :company, index: true, null: false
      t.string :form_id, index: true, null: false
      t.string :reference_id, index: true, null: false
      t.string :reference_type, index: true, null: false

      t.integer :created_by_id, index: true, references: 'users', foreign_key: true
      t.integer :updated_by_id, index: true, references: 'users', foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
    create_table :form_rules do |t|
      t.uuid :uuid
      t.references :company, index: true, null: false
      t.string :form_id, index: true, null: false
      t.string :rule_parent_id, index: true, null: false
      t.string :rule_parent_type, index: true, null: false
      t.string :form_entity_id, index: true, null: false
      t.string :predicate, null: false
      t.integer :rule_type_id, index: true, references: 'form_rule_types', foreign_key: true, null: false
      t.text :match_value
      t.string :match_formula
      t.string :match_entity_id, index: true, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end

    # For polymorphic relation
    add_index :form_rules, [:rule_parent_id, :rule_parent_type]
    add_index :form_conditions, [:reference_id, :reference_type]

    FormConditionType.seed_data
    FormRuleType.seed_data
  end
end
