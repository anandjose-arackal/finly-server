class CreateExportTemplateUserRoleMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :export_template_user_role_mappings do |t|
      t.integer :template_id, index: true, references: 'export_template_news', foreign_key: true, null: true
      t.integer :user_role_id, index: true, references: 'user_roles', foreign_key: true, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false
    end
  end
end
