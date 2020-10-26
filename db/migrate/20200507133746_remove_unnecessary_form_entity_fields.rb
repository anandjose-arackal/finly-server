class RemoveUnnecessaryFormEntityFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :form_entities, :field_key, :entity_key
    rename_column :form_entities, :field_path, :entity_path
    rename_column :form_entities, :field_type, :entity_type

    remove_column :form_entities, :chained
    remove_column :form_entities, :dependent
    remove_column :form_entities, :multiple
    remove_column :form_entities, :conditional_required
    remove_column :form_entities, :can_not_be_hidden
    remove_column :form_entities, :can_be_filtered
    remove_column :form_entities, :show_in_bulk_import
    remove_column :form_entities, :allow_sort_in_filter
    remove_column :form_entities, :associate_custom_fields

    add_column :form_entities, :type, :string, index: true
    add_column :form_entities, :config, :text
  end
end
