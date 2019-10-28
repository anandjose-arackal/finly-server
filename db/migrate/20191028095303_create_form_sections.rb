class CreateFormSections < ActiveRecord::Migration[5.2]
  def change
    create_table :form_sections do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.string :name, index: true, null: false
      t.references :form, index: true, null: false, foreign_key: true
      t.references :company, index: true, null: false, foreign_key: true
      t.boolean :active, index: true, default: true

      t.timestamps
    end
  end
end
