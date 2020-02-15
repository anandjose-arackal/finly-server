class AddFieldsToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :form_entities, :scope, :text
    add_column :form_entities, :internal, :boolean, default: false
    add_column :form_entities, :is_modified, :boolean, default: false
    add_column :form_entities, :field_path, :string, index: true
    add_column :form_entities, :parent_id, :string, index: true
    add_column :form_entities, :populate_if_empty, :string

    remove_column :form_sections, :section_type
    # remove_column :form_entities, :data_provider
  end
end
