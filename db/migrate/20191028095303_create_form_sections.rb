class CreateFormSections < ActiveRecord::Migration[5.2]
  def change
    create_table :form_sections do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.string :name, index: true, null: false
      t.string :form_id, index: true, null: false, limit: 36, foreign_key: true, references: 'forms'
      t.integer :company_id, index: true, null: false, foreign_key: true, references: 'companies'
      t.boolean :active, index: true, default: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
