class RestructureFormDependencies < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_choice_dependencies, :form_entity_id, :dependent_entity_id
    remove_column :form_choice_dependency_mappings, :form_rule_id
    rename_column :form_choice_dependency_mappings, :form_entity_choice_id, :dependent_choice_id
    add_column :form_choice_dependency_mappings, :controlling_choice_id, :string, index: true
  end
end
