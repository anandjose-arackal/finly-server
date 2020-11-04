class CreateFormEntityValidations < ActiveRecord::Migration[5.2]
  def change
    create_table :form_entity_validations do |t|
      t.uuid :uuid
      t.references :company, index: true, null: false
      t.string :form_id, index: true, null: false
      t.string :entity_path, index: true, null: false
      t.string :error_message, null: false
      t.integer :created_by_id, index: true, references: 'users'
      t.integer :updated_by_id, index: true, references: 'users'

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
