class CreateFormEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :form_entities do |t|
      t.integer :company_id, references: "Company", index: true, null: false, foreign_key: true
      t.integer :form_id, references: "Form", index: true, null: false, foreign_key: true
      t.integer :form_section_id, references: "FormSection", index: true, null: false, foreign_key: true
      t.integer :created_by_user_id, index: true, foreign_key: true, references: 'users'
      t.integer :parent_id, index: true
      t.string :field_key, index: true, null: false
      t.string :label
      t.boolean :placeholder
      t.boolean :hint
      t.boolean :field_type
      t.boolean :default_value
      t.boolean :editable
      t.boolean :required
      t.boolean :active
      t.boolean :unique
      t.boolean :visible
      t.boolean :position
      t.boolean :custom_field
      t.boolean :dependent
      t.boolean :conditional_requiredg
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

      t.timestamps index: true, null: false
    end
  end
end
