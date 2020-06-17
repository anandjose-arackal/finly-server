class AddHasDependentChoicesToFormDependencyMappings < ActiveRecord::Migration[5.2]
  def change
    add_column :form_dependency_mappings, :has_dependent_choices, :boolean
    add_column :form_dependency_mappings, :lazy_load_dependent_choices, :boolean
    add_column :form_dependency_choice_mappings, :controlling_entity_id, :string, index: true
    add_column :form_dependency_choice_mappings, :controlling_choice_id, :string, index: true
    add_column :form_dependency_choice_mappings, :controlling_choice_type, :string, index: true
  end
end
