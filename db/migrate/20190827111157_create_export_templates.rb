class CreateExportTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :export_templates do |t|
      t.string :name, index: true, null: false
      t.text :description
      t.string :template_type, index: true, null: false
      t.text :configuration, limit: 4294967295
      t.string :model_class, index: true, null: false
      t.boolean :active, index: true, default: true
      t.boolean :personal, index: true
      t.integer :created_by_user_id, index: true, null: false, references: 'users'
      t.integer :company_id, index: true, null: false, references: 'companies'

      t.timestamps
    end
  end
end
