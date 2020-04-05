class AddControllingEntityKeyToDependencies < ActiveRecord::Migration[5.2]
  def change
    add_column :form_dependencies, :controlling_entity_key, :string, index: true
    add_column :form_dependency_choice_mappings, :controlling_entity_key, :string, index: true
    add_column :form_dependencies, :dependent_entity_key, :string, index: true
    add_column :form_dependency_choice_mappings, :dependent_entity_key, :string, index: true

    add_column :form_dependency_mappings, :controlling_entity_id, :integer, index: true, references: "form_entities"
    add_column :form_dependency_mappings, :controlling_entity_key, :string, index: true
    add_column :form_dependency_mappings, :dependent_entity_id, :integer, index: true, references: "form_entities"
    add_column :form_dependency_mappings, :dependent_entity_key, :string, index: true
  end
end
