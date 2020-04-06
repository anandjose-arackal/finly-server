class CleanUpFormDependencyColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :form_dependencies, :form_id, :string, index: true, null: false
    remove_column :form_dependencies, :dependency_type_id
    remove_column :form_dependencies, :controlling_user_id
    rename_table :form_dependency_choices, :form_dependency_mappings
    add_column :form_dependency_mappings, :form_id, :string, index: true, null: false
    remove_column :form_dependency_mappings, :is_choice_selected
    rename_column :form_dependency_mappings, :dependent_entity_required, :dependent_required
    rename_column :form_dependency_mappings, :dependent_entity_visible, :dependent_visible
    rename_column :form_dependency_mappings, :dependent_entity_editable, :dependent_editable
    add_column :form_dependency_choice_mappings, :form_id, :string, index: true, null: false
    rename_column :form_dependency_choice_mappings, :form_dependency_choice_id, :form_dependency_mapping_id

    change_column :form_dependencies, :controlling_entity_id, :string, index: true
    change_column :form_dependencies, :dependent_entity_id, :string, index: true

    change_column :form_dependency_choice_mappings, :form_dependency_mapping_id, :string, index: true
    change_column :form_dependency_choice_mappings, :dependent_choice_id, :string, index: true
    change_column :form_dependency_mappings, :form_dependency_id, :string, index: true
    change_column :form_dependency_mappings, :controlling_choice_id, :string, index: true

    add_column :form_dependency_mappings, :controlling_choice_type, :string, index: true
    add_column :form_dependency_choice_mappings, :dependent_choice_type, :string, index: true

    drop_table :form_dependency_types
  end
end
