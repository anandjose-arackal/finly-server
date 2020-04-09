class CreateFormCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :form_custom_fields do |t|
      t.uuid
      t.string :document_type, index: true
      t.string :document_id, index: true
      t.string :form_id, index: true, null: false
      t.string :form_entity_id, index: true, null: false
      t.string :field_key, index: true, null: false
      t.string :value, index: true
      t.string :value_text, index: true
    end
    add_index :form_custom_fields, [:document_type, :document_id]

    add_column :form_sections, :associate_custom_fields, :boolean, default: false
    add_column :form_entities, :associate_custom_fields, :boolean, default: false
  end
end
