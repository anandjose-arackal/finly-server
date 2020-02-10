class CreateFormEntityChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :form_entity_choices do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.string :form_id, limit: 36, index: true, null: false, foreign_key: true, references: 'forms'
      t.string :form_section_id, limit: 36, index: true, null: false, foreign_key: true, references: 'forms_sections'
      t.string :form_entity_id, limit: 36, index: true, null: false, foreign_key: true, references: 'form_entities'
      t.integer :created_by_user_id, index: true, foreign_key: true, references: 'users'
      t.string :value, null: false
      t.integer :position, null: false
      t.boolean :active, default: true, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
