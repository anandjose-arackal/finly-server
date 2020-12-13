class CreateExportTemplateNews < ActiveRecord::Migration[5.2]
  def change
    create_table :export_template_news do |t|
      t.string :name, index: true, null: false
      t.text :description
      t.string :export_format, index: true, null: false
      t.string :resource, index: true, null: false
      t.text :template, limit: 4294967295
      t.text :query, limit: 4294967295
      t.boolean :active, index: true, default: true
      t.boolean :personal, index: true
      t.integer :company_id, foreign_key: true, index: true, references: 'companies'
      t.integer :created_by_id, foreign_key: true, index: true, references: 'users'
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
