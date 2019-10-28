class CreateFormSections < ActiveRecord::Migration[5.2]
  def change
    create_table :form_sections do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.string :name, index: true, null: false
      t.integer :form_id, references: "Form", foreign_key: true, index: true, null: false
      t.integer :company_id, references: "Company", foreign_key: true, index: true, null: false
      t.boolean :active, index: true, default: true

      t.timestamps
    end
  end
end
