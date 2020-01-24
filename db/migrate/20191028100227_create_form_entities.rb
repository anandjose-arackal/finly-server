class CreateFormEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :form_entities do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.integer :company_id, index: true, null: false, foreign_key: true, references: 'companies'
      t.string :form_id, index: true, null: false, foreign_key: true, limit: 36, references: 'forms'
      t.string :form_section_id, index: true, null: false, foreign_key: true, limit: 36, references: 'forms_sections'
      t.integer :created_by_user_id, index: true, foreign_key: true, references: 'users'
      t.string :parent_id, index: true
      t.string :field_key, index: true, null: false
      t.string :label
      t.string :placeholder
      t.string :hint
      t.string :field_type
      t.string :default_value
      t.boolean :multiple
      t.boolean :editable
      t.boolean :required
      t.boolean :active
      t.boolean :unique
      t.boolean :visible
      t.integer :position
      t.boolean :custom_field
      t.boolean :dependent
      t.boolean :conditional_required
      t.boolean :can_visible_be_changed
      t.boolean :can_editable_be_changed
      t.boolean :can_required_be_changed
      t.boolean :can_uniqueness_be_changed
      t.boolean :can_be_disabled
      t.boolean :can_label_be_renamed
      t.boolean :can_not_be_hidden
      t.boolean :can_be_filtered
      t.boolean :can_choices_be_changed
      t.boolean :show_in_bulk_import
      t.boolean :allow_sort_in_filter
      t.boolean :allow_clearing_default_value
      t.text :options
      t.text :chained
      t.text :data_provider

      t.datetime :deleted_at, index: true
      t.timestamps index: true, null: false
    end
  end
end
