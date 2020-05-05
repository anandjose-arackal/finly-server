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
      t.references :form, foreign_key: true, index: true, null: false
      t.references :reference, polymorphic: true, index: true, null: false
      t.string :form_entity_key, index: true, null: false
      t.integer :condition_type_id, references: 'form_entity_condition_types', index: true, foreign_key: true, null: false

      t.integer :created_by_id, index: true, references: 'users', foreign_key: true
      t.integer :updated_by_id, index: true, references: 'users', foreign_key: true

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
    create_table :form_rules do |t|
      t.uuid :uuid
      t.references :company, index: true, null: false
      t.references :form, foreign_key: true, index: true, null: false
      t.references :rule_parent, polymorphic: true, index: true
      t.references :form_entity, foreign_key: true, index: true, null: false
      t.string :predicate, null: false
      t.string :rule_type_id, index: true, references: 'form_rule_types', foreign_key: true, null: false
      t.text :match_value
      t.string :match_formula
      t.integer :match_entity_id, references: 'form_entities', index: true, foreign_key: true, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
    FormConditionType.seed_data
    FormRuleType.seed_data
  end
end
