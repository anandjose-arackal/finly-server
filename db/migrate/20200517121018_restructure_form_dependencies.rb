class RestructureFormDependencies < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_choice_dependencies, :form_entity_id, :dependent_entity_id
    remove_column :form_choice_dependency_mappings, :form_rule_id
    rename_column :form_choice_dependency_mappings, :form_entity_choice_id, :dependent_choice_id
    add_column :form_choice_dependency_mappings, :controlling_choice_id, :string, index: true
    remove_index :form_conditions, :reference_type
    remove_index :form_conditions, :reference_key
    remove_column :form_conditions, :reference_type
    remove_column :form_conditions, :reference_key

    add_column :form_conditions, :referencable_id, :string, index: true, null: false
    add_column :form_conditions, :referencable_type, :string, index: true, null: false
    add_index :form_conditions, [:referencable_id, :referencable_type]
    add_column :form_entity_validations, :form_entity_id, :string, index: true, null: false
    remove_column :form_entity_validations, :entity_path
  end
end
